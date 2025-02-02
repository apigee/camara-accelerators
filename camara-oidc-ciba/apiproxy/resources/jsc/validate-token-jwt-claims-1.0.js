
// Get the JWT request parameters.
var clientAssertionTypeJWTIssuer = context.getVariable("jwt.JWT-ValidateClientAssertionParameter.claim.issuer");
var clientAssertionTypeSubject = context.getVariable("jwt.JWT-ValidateClientAssertionParameter.claim.subject");


// Define the required parameters.
var requiredParams = {
    "subject": clientAssertionTypeSubject,
    "iss": clientAssertionTypeJWTIssuer
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
if (clientAssertionTypeSubject !== clientAssertionTypeJWTIssuer) {
  context.setVariable("error_type", "unauthorized_request");
  context.setVariable("error_variable", "The 'sub' claim and the 'iss' in the 'client_assertion' parameter must have the same value.");
  context.setVariable("status_code", "401");
}