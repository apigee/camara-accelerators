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

var grant_type = context.getVariable("request.formparam.grant_type");
var code = context.getVariable("request.formparam.code");
var redirect_uri = context.getVariable("request.formparam.redirect_uri");
var code_verifier = context.getVariable("request.formparam.code_verifier");

var requiredParams = {
    "redirect_uri": redirect_uri,
    "code": code,
    "grant_type": grant_type,
    "code_verifier": code_verifier
};

for (var paramName in requiredParams) {
    if (!requiredParams[paramName]) {
        context.setVariable("error_type", "invalid_request");
        context.setVariable("error_variable", "The request is missing a required parameter: " + paramName);
        context.setVariable("status_code", "400");
        break;
    }
}

if(grant_type != "authorization_code"){
  context.setVariable("error_type", "invalid_request");
  context.setVariable("error_variable", "Invalid grant_type: " + grant_type);
  context.setVariable("status_code", "400");
}