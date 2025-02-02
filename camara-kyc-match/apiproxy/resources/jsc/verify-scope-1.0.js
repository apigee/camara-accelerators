/**
 * This code snippet validates the presence of an expected scope within a set of consented scopes.
 * It retrieves the consented and expected scopes from context variables, checks if the expected scope
 * is included within the consented scopes, and sets error variables if the expected scope is not found.
 */

// Retrieve the consented scopes from the context variable.
var consentedScopes = context.getVariable("scope");

// Retrieve the expected scope from the context variable. This scope is defined in a property set named "simswap".
var expectedScope = context.getVariable("propertyset.kyc-match.scope");

/**
 * Splits the consented scopes string into an array of individual scopes.
 *
 * @param {string} consentedScopes - A space-separated string of consented scopes.
 * @returns {string[]} An array of individual consented scopes.
 */
function splitScopes(consentedScopes) {
  if (typeof consentedScopes === 'string' && consentedScopes.trim() !== '') {
    return consentedScopes.split(" ");
  } else {
    return [];
  }
}

// Convert the consented scopes string into an array.
consentedScopes = splitScopes(consentedScopes);

/**
 * Validates whether the expected scope is present within the array of consented scopes.
 * Sets error variables in the context if the expected scope is not found.
 *
 * @param {string[]} consentedScopes - An array of consented scopes.
 * @param {string} expectedScope - The expected scope to validate.
 */
function validateScope(consentedScopes, expectedScope) {
  if (!consentedScopes.includes(expectedScope)) {
    // Set the error type to "unauthorized".
    context.setVariable("error_type", "unauthorized");
    // Set a descriptive error message.
    context.setVariable("error_variable", "Invalid scope");
    // Set the HTTP status code to 401 (Unauthorized).
    context.setVariable("status_code", "401");
  }
}

// Validate the presence of the expected scope.
validateScope(consentedScopes, expectedScope);