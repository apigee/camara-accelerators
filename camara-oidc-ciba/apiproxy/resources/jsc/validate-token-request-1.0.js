/**
 * This script validates the incoming request for a CIBA (Client Initiated Backchannel Authentication) token request.
 * It checks for the presence of required parameters and ensures their values conform to the expected types.
 *
 * **Required Parameters:**
 *
 *   - `grant_type`: Must be `urn:openid:params:grant-type:ciba`.
 *   - `auth_req_id`: The authentication request ID obtained from the initial authentication request.
 *   - `client_assertion_type`: Must be `urn:ietf:params:oauth:client-assertion-type:jwt-bearer`.
 *   - `client_assertion`: The JWT client assertion.
 *
 * **Error Handling:**
 *
 * The script sets the following context variables in case of an error:
 *
 *   - `error_type`: Set to `invalid_request`.
 *   - `error_variable`: A descriptive message indicating the specific error.
 *   - `status_code`: Set to `400` (Bad Request).
 *
 * **Flow of Execution:**
 *
 * 1. **Extracts Parameters:** The script first retrieves the values of the `grant_type`, `auth_req_id`, `client_assertion_type`, and `client_assertion` parameters from the request form parameters using `context.getVariable()`.
 * 2. **Defines Required Parameters:** It then defines an object `requiredParams` containing the expected parameters and their extracted values.
 * 3. **Validates Presence:** It iterates through the `requiredParams` object and checks if each parameter has a value. If a required parameter is missing, it sets the error context variables and uses `break` to stop further processing.
 * 4. **Validates `client_assertion_type`:** If all required parameters are present, it validates the `client_assertion_type`. If it's not equal to `urn:ietf:params:oauth:client-assertion-type:jwt-bearer`, it sets the error context variables and uses `break` to stop further processing.
 * 5. **Validates `grant_type`:**  If `client_assertion_type` is valid, it validates the `grant_type`. If it's not equal to `urn:openid:params:grant-type:ciba`, it sets the error context variables and uses `break` to stop further processing.
 */

var grant_type = context.getVariable("request.formparam.grant_type");
var auth_req_id = context.getVariable("request.formparam.auth_req_id");
var client_assertion_type = context.getVariable("request.formparam.client_assertion_type");
var client_assertion = context.getVariable("request.formparam.client_assertion");

/**
 * @type {object}
 * @property {string} grant_type - The grant type of the request, should be urn:openid:params:grant-type:ciba.
 * @property {string} auth_req_id - The authentication request ID.
 * @property {string} client_assertion_type - The type of client assertion, should be urn:ietf:params:oauth:client-assertion-type:jwt-bearer.
 * @property {string} client_assertion - The client assertion value.
 */
var requiredParams = {
    "grant_type": grant_type,
    "auth_req_id": auth_req_id,
    "client_assertion_type": client_assertion_type,
    "client_assertion": client_assertion
};

for (var paramName in requiredParams) {
    if (!requiredParams[paramName]) {
        context.setVariable("error_type", "invalid_request");
        context.setVariable("error_variable", "The request is missing a required parameter: " + paramName);
        context.setVariable("status_code", "400");
        break;
    }
}

if(client_assertion_type != "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"){
  context.setVariable("error_type", "invalid_request");
  context.setVariable("error_variable", "Invalid client_assertion_type: " + client_assertion_type);
  context.setVariable("status_code", "400");
}

if(grant_type != "urn:openid:params:grant-type:ciba"){
  context.setVariable("error_type", "invalid_request");
  context.setVariable("error_variable", "Invalid grant_type: " + grant_type);
  context.setVariable("status_code", "400");
}
