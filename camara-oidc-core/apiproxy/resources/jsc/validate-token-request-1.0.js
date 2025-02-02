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