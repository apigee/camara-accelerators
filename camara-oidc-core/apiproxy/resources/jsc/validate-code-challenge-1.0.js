

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