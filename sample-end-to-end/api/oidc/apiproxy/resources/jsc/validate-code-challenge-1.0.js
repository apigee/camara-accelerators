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

var code_challenge = context.getVariable("oauthv2authcode.OAuthV2-GetCodeChallenge.code_challenge");
var code_verifier = context.getVariable("request.formparam.code_verifier");

if(!verifyCodeChallenge(code_verifier,code_challenge)){
  context.setVariable("error_type", "invalid_request");
  context.setVariable("error_variable", "Parameter mismatch with code_verifier and code_challenge");
  context.setVariable("status_code", "400");
}

function verifyCodeChallenge(codeVerifier, codeChallenge) {
  if (!codeVerifier || !codeChallenge) {
    return false; // Or throw an error if that's more appropriate for your use case
  }
    const sha256 = crypto.getSHA256(); // Assuming 'crypto' is defined and has getSHA256()
    sha256.update(codeVerifier);
    const computedChallenge = sha256.digest64().replace(/=+$/, '').replace(/\+/g, '-').replace(/\//g, '_');
   
    context.setVariable("computedChallenge", computedChallenge);
    
    return computedChallenge === codeChallenge;
 
}