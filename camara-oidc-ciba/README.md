# Deploy CIBA Facade for CAMARA Interoperability Profile

This sample proxy creates a facade layer for OpenID Connect Client Initiated Backchannel Authentication or [CIBA](https://openid.net/specs/openid-client-initiated-backchannel-authentication-core-1_0.html) that aims to comply with the [CAMARA Security and Interoperability Profile](https://github.com/camaraproject/IdentityAndConsentManagement/blob/main/documentation/CAMARA-Security-Interoperability.md). This API Proxy can be used in front of your IdP and it will enforce CAMARA requirements for CIBA such as request and client assertion parameters, scopes given to a certain client ID, generation of the auth_req_id parameter, validate JWT claims, validate login_hint and generate errors when the parameter don't match.

This folder also includes a "mock" backend, which is implemented as an Apigee Proxy, that will mock responses around backend user approval and consent. In real life, you would adapt this proxy, either via its target server config or any other strategy, to reach out to your IdP and consent solution.

## Screencast

TBD

## Prerequisites

1. [Provision Apigee X](https://cloud.google.com/apigee/docs/api-platform/get-started/provisioning-intro)
2. Access to create and deploy Apigee proxies, KVMs and Target Servers
3. Configure [external access](https://cloud.google.com/apigee/docs/api-platform/get-started/configure-routing#external-access) for API traffic to your Apigee X instance
4. Make sure the following tools are available in your terminal's $PATH (Cloud Shell has these pre-configured)
   - [gcloud SDK](https://cloud.google.com/sdk/docs/install)
   - unzip
   - curl
   - jq
   - npm

## (QuickStart) Setup using CloudShell

Use the following GCP CloudShell tutorial, and follow the instructions.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/carlosmscabral/apigee-camara-staging&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=camara-oidc-ciba/docs/cloudshell-tutorial.md)

## Setup instructions

1. Clone the Apigee CAMARA repo, and switch the camara-oidc-ciba directory

```bash
git clone https://github.com/carlosmscabral/apigee-camara-staging.git
cd apigee-camara-staging/camara-oidc-ciba
```

2. Edit the `env.sh` and configure the ENV vars

- `APIGEE_PROJECT_ID` the project where your Apigee organization is located
- `APIGEE_ENV` the Apigee environment where the demo resources should be created
- `APIGEE_HOST` the Apigee host URL (please include protocol, such as https://my.apigeedomain.com)
- `CLIENT_JKWS_URI` the URI for the JWKS used to sign client assertions so Apigee can validate them
- `CIBA_TARGET_SERVER_URI` the URI (without http or https) to your backend consent/IdP system
- `CIBA_TARGET_SERVER_PATH` the path to your backend consent/IdP system such as "/camara-oidc-ciba-bknd-mock"
- `PRIVATE_KEY` the private key to be used by Apigee to sign the final ID token. It is stored in a KVM
- `USE_MOCK` true or false, wheter you want to use the provided sample backend for CIBA

Now source the `env.sh` file

```bash
source ./env.sh
```

3. Simply deploy the assets with the following command

```bash
./deploy-ciba.sh
```

The deployment script will create the proxy, optionally the mock backend proxy, and also the Target Server and KVM as described above.

## Verify the setup

Feel free to navigate to the Google Cloud Console Apigee for verifying the created proxies. Generate sample calls towards the proxy, generating client assertions and requests as per CAMARA CIBA requirements.

## Cleanup

If you want to clean up the artifacts from this example in your Apigee Organization, first source your `env.sh` script, and then run

```bash
./clean-up-ciba.sh
```
