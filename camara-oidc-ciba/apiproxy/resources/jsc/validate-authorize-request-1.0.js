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
 * @fileoverview This script validates an authorize request, ensuring the presence of required parameters.
 * It checks for 'request', 'client_assertion_type', and 'client_assertion' in the request form parameters.
 * If any of these parameters are missing or empty, it sets error variables to indicate an invalid request.
 */

/**
 * @description Validates the presence and non-emptiness of required parameters in an authorize request.
 *
 * @param {object} context - The Apigee context object.
 *
 * @example
 * // Assuming the following request parameters are present:
 * // request.formparam.request = "some_request_value"
 * // request.formparam.client_assertion_type = "some_assertion_type"
 * // request.formparam.client_assertion = "some_assertion_value"
 *
 * // This script will execute without setting any error variables.
 *
 * @example
 * // Assuming the following request parameters are present:
 * // request.formparam.request = ""
 * // request.formparam.client_assertion_type = "some_assertion_type"
 * // request.formparam.client_assertion = "some_assertion_value"
 *
 * // This script will set the following context variables:
 * // error_type = "invalid_request"
 * // error_variable = "The request is missing a required parameter: request"
 * // status_code = "400"
 */

var requestPayload = context.getVariable("request.formparam.request");
var client_assertion_type = context.getVariable("request.formparam.client_assertion_type");
var client_assertion = context.getVariable("request.formparam.client_assertion");

/**
 * @type {object}
 * @property {string} request - The request payload.
 * @property {string} client_assertion_type - The type of client assertion.
 * @property {string} client_assertion - The client assertion value.
 */
var requiredParams = {
    "request": requestPayload,
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