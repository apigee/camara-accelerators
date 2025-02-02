/**
 * This code validates the JWT request parameters.
 * It checks for the presence of required parameters and validates their values.
 *
 * **Required Parameters:**
 *
 *   - `iss`: The issuer claim from the JWT-ValidateRequestParameter, this should match the `client_assertion` issuer.
 *   - `client_assertion`: The issuer claim from the JWT-ValidateClientAssertionParameter, effectively the client_id.
 *   - `login_hint`: A hint about the login identifier the End-User might use to log in (if necessary).
 *
 * **Error Handling:**
 *
 * The script sets the following context variables in case of an error:
 *
 *   - `error_type`:
 *     - `invalid_request`: Indicates a missing or invalid parameter.
 *     - `unauthorized_request`: Indicates a mismatch between `iss` claims.
 *   - `error_variable`: A descriptive message indicating the specific error.
 *   - `status_code`:
 *     - `400` (Bad Request): For missing or invalid parameters.
 *     - `401` (Unauthorized): For a mismatch in the `iss` claims.
 *
 * **Flow of Execution:**
 *
 * 1. **Retrieves JWT Claims:** Extracts `issuer` claims from two different JWT verification policies (`JWT-ValidateClientAssertionParameter` and `JWT-ValidateRequestParameter`) and the `login_hint` claim.
 * 2. **Defines Required Parameters:** Creates an object `requiredParams` to hold the expected parameters and their extracted values.
 * 3. **Validates Presence:** Iterates through `requiredParams` and checks if each parameter is present. If a parameter is missing, it sets the error context variables and `break`s the loop.
 * 4. **Validates Issuer Match:** Compares the `iss` claim from the request JWT (`requestJWTIssuer`) with the `iss` claim from the client assertion JWT (`clientAssertionTypeJWTIssuer`). If they don't match, it sets the error context variables indicating an unauthorized request.
 * 5. **Validates `login_hint` Format:** Uses a regular expression (`/^tel:\+?\d{1,14}$/`) to validate that the `login_hint` claim, if present, conforms to a specific format, presumed to be a phone number format. If the format is invalid, it sets the error context variables.
 */

// Get the JWT request parameters.
var clientAssertionTypeJWTIssuer = context.getVariable("jwt.JWT-ValidateClientAssertionParameter.claim.issuer");
var requestJWTIssuer = context.getVariable("jwt.JWT-ValidateRequestParameter.claim.issuer");
var loginHint = context.getVariable("jwt.JWT-ValidateClientAssertionParameter.claim.login_hint");

// Define the required parameters.
var requiredParams = {
    "iss": requestJWTIssuer,
    "client_assertion": clientAssertionTypeJWTIssuer,
    "login_hint": loginHint
};

// Check if all required parameters are present.
for (var paramName in requiredParams) {
    if (!requiredParams[paramName]) {
        context.setVariable("error_type", "invalid_request");
        context.setVariable("error_variable", "The request is missing a required parameter: " + paramName);
        context.setVariable("status_code", "400");
        break; // Exit the loop if a parameter is missing.
    }
}

// Check if the issuer in the request and client_assertion parameters match.
if (requestJWTIssuer !== clientAssertionTypeJWTIssuer) {
  context.setVariable("error_type", "unauthorized_request");
  context.setVariable("error_variable", "The 'iss' claim in the signed authentication request and the 'client_assertion' parameter must have the same value.");
  context.setVariable("status_code", "401");
}

// Validate the login_hint parameter using a regular expression.
var re = new RegExp(/^tel:\+?\d{1,14}$/);
if (!re.test(loginHint)) {
  context.setVariable("error_type", "invalid_request");
  context.setVariable("error_variable", "The request parameter login_hint is invalid");
  context.setVariable("status_code", "400");
}