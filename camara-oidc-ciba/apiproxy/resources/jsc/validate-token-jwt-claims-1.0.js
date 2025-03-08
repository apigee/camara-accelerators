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