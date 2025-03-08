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
 * Checks if a given MSISDN (Mobile Station International Subscriber Directory Number)
 * is present in a predefined list of allowed MSISDNs.  This might be used for
 * whitelisting or testing purposes.
 *
 * @param {object} context The Apigee context object. It is expected to have the following methods:
 *                         - `getVariable(variableName)`: Retrieves the value of a variable.
 *                         - `setVariable(variableName, value)`: Sets the value of a variable.
 *
 * @returns {void} This function does not return a value. It sets the "status" variable
 *                 in the Apigee context to a boolean indicating whether the MSISDN
 *                 is in the allowed list.
 *
 * @example
 * // Example usage within an Apigee policy:
 * // <script>
 * //   // ... (Code as provided in the prompt)
 * // </script>
 */

/**
 * Retrieves the MSISDN from the Apigee context.  It is assumed that a previous
 * policy or service has populated the "msisdn" variable.
 */
var msisdn = context.getVariable("msisdn");

/**
 * Array containing the allowed MSISDNs.  It is *crucial* to keep this list
 * secure and up-to-date.  For production environments, storing this list in
 * a more secure and manageable location (e.g., a KeyValueMap or external
 * configuration) is strongly recommended.  Hardcoding sensitive data
 * directly in the script is a security risk.
 */
var allowedMsisdns = ["+34678668000"]; // Example MSISDN.  REPLACE THIS WITH YOUR ACTUAL LIST.

/**
 * Checks if the provided MSISDN is present in the allowed MSISDNs array.
 * The `includes()` method is used for efficient searching.
 */
var status = allowedMsisdns.includes(msisdn);

/**
 * Sets the "status" variable in the Apigee context to the result of the check.
 * This variable can then be used in subsequent policies or conditions to control
 * the flow of the API request (e.g., to allow or deny access based on the MSISDN).
 */
context.setVariable("status", status);

// No explicit return is needed as the function modifies the Apigee context directly.