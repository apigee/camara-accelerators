/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * This script validates the requested scopes against the allowed scopes defined in the API Product.
 * It retrieves the requested scopes from a JWT claim and the allowed scopes from an AccessEntity policy.
 *
 * **Scope Validation:**
 *
 * The script performs the following checks:
 *
 * 1. **Retrieves Scopes:**
 *    - `scopes`: Requested scopes from the `scope` claim of the `JWT-ValidateClientAssertionParameter` JWT.
 *    - `scopesXMLString`: Allowed scopes from the `ApiProduct.Scopes` of the `AE-GetAPIProductScopes` AccessEntity policy, represented as an XML string.
 * 2. **Validates Using `validateScopes` Function:** Calls the `validateScopes` function to compare the requested scopes against the allowed scopes.
 * 3. **Sets Error Variables (if invalid):** If the `validateScopes` function returns `false` (indicating invalid scopes), the script sets the following context variables:
 *    - `error_type`: Set to `invalid_scope`.
 *    - `error_variable`: Set to `The requested scope is invalid, unknown, or malformed`.
 *    - `status_code`: Set to `400` (Bad Request).
 *
 * **`validateScopes` Function Details:**
 *
 * This function checks if the provided `applicationScope` (requested scopes) is valid against the `scopesXMLString` (allowed scopes from API Product).
 *
 * **Parameters:**
 *
 *   - `scopesXMLString` (String): An XML string representing the allowed scopes from the API Product. This string is expected to be in the format `<Scopes><Scope>scope1</Scope><Scope>scope2</Scope>...</Scopes>`.
 *   - `applicationScope` (String): A space-separated string of scopes requested by the application.
 *
 * **Return Value:**
 *
 *   - `true`: If all requested scopes are present within the allowed scopes in the API Product.
 *   - `false`: If any of the requested scopes are not found in the allowed scopes or if either input is null/undefined.
 *
 * **Logic:**
 *
 * 1. **Handles Empty/Null Input:** Returns `false` immediately if either `applicationScope` or `scopesXMLString` is null or undefined.
 * 2. **Parses Requested Scopes:** Splits the `applicationScope` string by spaces into an array of individual scopes.
 * 3. **Removes XML Declaration (Workaround):** Removes the XML declaration (e.g., `<?xml version="1.0" encoding="UTF-8"?>`) from the beginning of `scopesXMLString`. This is a workaround to handle potential issues with parsing the XML.
 * 4. **Parses XML:** Parses the modified `scopesXMLString` into an XML object using E4X.
 * 5. **Creates Allowed Scopes Object:** Iterates through the `<Scope>` elements in the XML and creates an object `allowedScopes` where keys are the allowed scope values and values are `true`.
 * 6. **Validates Each Requested Scope:** Uses the `every` method to check if each requested scope exists as a key in the `allowedScopes` object. Returns `true` only if all requested scopes are found, otherwise returns `false`.
 */

var scopes = context.getVariable("jwt.JWT-ValidateClientAssertionParameter.claim.scope");
var scopesXMLString = context.getVariable("AccessEntity.AE-GetAPIProductScopes.ApiProduct.Scopes");

if (!validateScopes(scopesXMLString, scopes)) {
  context.setVariable("error_type", "invalid_scope");
  context.setVariable("error_variable", "The requested scope is invalid, unknown, or malformed");
  context.setVariable("status_code", "400");
}

/**
 * Validates the application scopes against the API Product scopes using E4X.
 *
 * @param {String} scopesXMLString The XML string containing allowed scopes from API Product.
 * @param {String} applicationScope The space-separated string of scopes from the application request.
 *
 * @return {boolean} True if all application scopes are valid, false otherwise.
 */
function validateScopes(scopesXMLString, applicationScope) {
  if (!applicationScope || !scopesXMLString) {
    return false;
  }

  const receivedScopes = applicationScope.split(" ");

  // Workaround to remove XML declaration
  scopesXMLString = scopesXMLString.replace(/^<\?xml\s+version\s*=\s*(["'])[^\1]+\1[^?]*\?>/, "");
  
  // Create an XML object
  const scopesXML = new XML(scopesXMLString);

  const allowedScopes = {};
  
  // iteration to extract allowed scopes
  for each (var scope in scopesXML..Scope) {
    allowedScopes[scope.toString()] = true;
  }

  // check for invalid scopes
  return receivedScopes.every(function(scope) {
    return allowedScopes.hasOwnProperty(scope);
  });
}