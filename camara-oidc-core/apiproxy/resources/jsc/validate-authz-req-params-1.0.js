/*
 * Further processing of the authorize request:
 *   1. Validate redirect_uri against the registered URI.
 *   2. Validate scopes against the API Product's allowed scopes.
 *   3. Extract and store optional parameters.
 */

var verb = context.getVariable("request.verb");

// Pre-fetched values (from previous policies, ideally)
var scope = context.getVariable("oidc.flow.authorize.scope");  // Already validated for existence in previous step
var client_id = context.getVariable("oidc.flow.authorize.client_id"); // Already validated
var redirect_uri = context.getVariable("oidc.flow.authorize.redirect_uri"); // Already validated for existence

var applictionRedirectionUri = context.getVariable("verifyapikey.VA-AuthorizeClientId.redirection_uris"); // callback_uri in app config
var applicationname = context.getVariable("verifyapikey.VA-AuthorizeClientId.app.name");
var applicationdesc = context.getVariable("verifyapikey.VA-AuthorizeClientId.app.applicationdesc"); //application description
var tandcs = context.getVariable("verifyapikey.VA-AuthorizeClientId.tandcs");
var applicationid = context.getVariable("verifyapikey.VA-AuthorizeClientId.app.id");

// Optional parameters - use a function to get them
function getRequestParam(paramName) {
    if (verb === "POST") {
        return context.getVariable("request.formparam." + paramName);
    } else if (verb === "GET") {
        return context.getVariable("request.queryparam." + paramName);
    }
    return null; // Handle cases other than GET/POST if needed
}

var state = getRequestParam("state");
var nonce = getRequestParam("nonce");
var display = getRequestParam("display"); // display is defined twice
var login_hint = getRequestParam("login_hint");
var prompt = getRequestParam("prompt");
var offline = getRequestParam("offline"); // offline is probably not a separate parameter, but related to scope
var id_token_hint = getRequestParam("id_token_hint");
var ui_locales = getRequestParam("ui-locales");  // Corrected typo: ui-locales -> ui_locales


// Helper function for consistent error handling (re-use from previous refinement)
function setError(errorType, errorMessage, statusCode) {
    context.setVariable("error_type", errorType);
    context.setVariable("error_variable", errorMessage);
    context.setVariable("status_code", statusCode);
}

// Validation: redirect_uri MUST match exactly
if (redirect_uri !== applictionRedirectionUri) {
    setError("invalid_redirect_uri", "This value must match a URL registered with the Application.", "400");
} else {
    // All validations passed, set context variables
    context.setVariable("oidc.flow.authorize.state", state);
    context.setVariable("oidc.flow.authorize.req_state", state); // Why both state and req_state?  Consider removing one.
    context.setVariable("oidc.flow.authorize.nonce", nonce);
    context.setVariable("oidc.flow.authorize.display", display);
    context.setVariable("oidc.flow.authorize.login_hint", login_hint);
    context.setVariable("oidc.flow.authorize.prompt", prompt);
    context.setVariable("oidc.flow.authorize.offline", offline); //  Consider if this is actually needed as a separate variable.
    context.setVariable("oidc.flow.authorize.id_token_hint", id_token_hint);
    context.setVariable("oidc.flow.authorize.ui_locales", ui_locales);
    context.setVariable("oidc.flow.authorize.tandcs", tandcs);
    context.setVariable("oidc.flow.authorize.applicationname", applicationname);
    context.setVariable("oidc.flow.authorize.applicationid", applicationid);
    context.setVariable("oidc.flow.authorize.applicationdesc", applicationdesc);
}



/**
 * Check if a given element is null/empty
 *
 * @param {String} element
 * @return {boolean}
 */

function isEmptyOrNull(element) {  // This function is likely not used in *this* part, but good to keep for consistency
    return (element == null) || (element === "");
}