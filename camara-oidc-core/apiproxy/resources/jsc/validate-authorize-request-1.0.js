/*
 * Validate the authorize request from query or body parameter
 *   1. Check for empty client_id
 *   2. Validate response_type parameter - http://openid.net/specs/oauth-v2-multiple-response-types-1_0.html
 *   3. Validate scope
 *   4. Check for empty redirect_uri parameter
 *   5. Check for empty state parameter  (State is not mandatory - removed check)
 * validate-request-1.0.js (c) 2010-2015 @Apigee
 */

var verb = context.getVariable("request.verb");
var re = new RegExp(/^tel:\+?\d{1,14}$/);

var response_type = null;
var scope = null;
var client_id = null;
var redirect_uri = null;
var acr_values = null;
var login_hint = null;
var code_challenge = null;

// Function to extract parameters - handles both GET and POST
function getRequestParam(paramName) {
  if (verb === "POST") {
    return context.getVariable("request.formparam." + paramName);
  } else if (verb === "GET") {
    return context.getVariable("request.queryparam." + paramName);
  }
  return null; // Or throw an error if neither GET nor POST
}

// Extract all parameters
code_challenge = getRequestParam("code_challenge");
response_type = getRequestParam("response_type");
scope = getRequestParam("scope");
client_id = getRequestParam("client_id");
redirect_uri = getRequestParam("redirect_uri");
acr_values = getRequestParam("acr_values");
login_hint = getRequestParam("login_hint");

context.setVariable("debug.js.login_hint",login_hint);


// Helper function for consistent error handling
function setError(errorType, errorMessage, statusCode) {
  context.setVariable("error_type", errorType);
  context.setVariable("error_variable", errorMessage);
  context.setVariable("status_code", statusCode);
}

// Validation checks - Improved readability and order of operations
if (isEmptyOrNull(client_id)) {
  setError("invalid_client", "Unknown client_id.", "401");  // 401 for invalid client
} else if (isEmptyOrNull(response_type)) {
  setError("invalid_request", "The request is missing a required parameter: response_type", "400");
} else if (isEmptyOrNull(redirect_uri)) {
  setError("invalid_request", "The request is missing a required parameter: redirect_uri", "400");
} else if (isEmptyOrNull(scope)) {
  setError("invalid_request", "The request is missing a required parameter: scope", "400");
} else if ((scope.toLowerCase()).indexOf("openid") === -1) {
  setError("invalid_scope", "The request is missing a required scope parameter: openid", "400");
} else if (isEmptyOrNull(login_hint)) {
  setError("login_hint", "The request is missing a required parameter: login_hint", "400");
} else if (!re.test(login_hint)) {
  setError("invalid_request", "The request parameter login_hint is invalid", "400");
} else if (isEmptyOrNull(code_challenge)) {
  setError("invalid_client", "Unknown code_challenge.", "400");
} else {
  // All required parameters are present, proceed with further validation
  context.setVariable("oidc.flow.authorize.redirect_uri", redirect_uri);
  context.setVariable("oidc.flow.authorize.scope", scope);
  context.setVariable("oidc.flow.authorize.response_type", response_type);
  context.setVariable("oidc.flow.authorize.client_id", client_id);
  context.setVariable("oidc.flow.authorize.login_hint", login_hint);
  context.setVariable("oidc.flow.authorize.code_challenge", code_challenge);

  //  Handle acr_values (default value if missing)
  context.setVariable("oidc.flow.authorize.acr_values", isEmptyOrNull(acr_values) ? "2" : acr_values);


  if (!parseResponseType(response_type)) {
    setError("unsupported_response_type", "The authorization server does not support: response_type", "400");
  }
}

/**
 * Check if a given element is null/empty
 *
 * @param {String} element
 * @return {boolean}
 */
function isEmptyOrNull(element) {
  return (element == null) || (element === "");
}


/**
 * Parse response_type. OpenId connect can support multiple response_type
 * for more information - http://openid.net/specs/oauth-v2-multiple-response-types-1_0.html
 * for e.g. a combination of code, token and id_token.
 * This will be used to conditionally execute GenerateIDToken, AuthorizationCode & AccessToken policies
 * @param {String} responseType - Space separated string e.g."code id_token token"
 *
 * @return void
 */
function parseResponseType(responseType) {
  if (!responseType) { // Handle null or undefined responseType
        return false;
    }
  var responseTypes = responseType.split(" ");
  var response_type_code = false;
  var response_type_token = false;
  var response_type_id_token = false;
  var bStatus = false; // Initialize bStatus to false
  var errorResponseSymbol = "?";

  for (var j = 0; j < responseTypes.length; j++) {
    switch (responseTypes[j]) {
      case "code":
        response_type_code = true;
        bStatus = true; // Set bStatus to true if at least one valid type is found
        break;
      case "token":
        response_type_token = true;
        bStatus = true;
        break;
      case "id_token":
        response_type_id_token = true;
        bStatus = true;
        break;
      //  No default case needed, just ignore unknown response types.
    }
  }

  if (response_type_token || response_type_id_token) {
    errorResponseSymbol = "#";
  }

  context.setVariable("error_response_symbol", errorResponseSymbol);
  context.setVariable("response_type_token", response_type_token);
  context.setVariable("response_type_id_token", response_type_id_token);
  context.setVariable("response_type_code", response_type_code);
  return bStatus;
}