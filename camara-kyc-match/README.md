# CAMARA Know Your Customer (KYC) Match API

This sample proxy creates an implementation of the [CAMARA KYC Match](https://github.com/camaraproject/KnowYourCustomer). It validates the expected parameters as per the spec, validates the provided access token (to be retrieved using one of the supported CAMARA Authorization flows) and also validates the required scopes for each of the API operations. Descriptive errors are also created in scenarios where scopes don't match, parameters are invalid and so on.

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

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/carlosmscabral/apigee-camara-staging&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=camara-kyc-match/docs/cloudshell-tutorial.md)

## Setup instructions

1. Clone the Apigee CAMARA repo, and switch the camara-kyc-match directory

```bash
git clone https://github.com/carlosmscabral/apigee-camara-staging.git
cd apigee-camara-staging/camara-kyc-match
```

2. Edit the `env.sh` and configure the ENV vars

- `APIGEE_PROJECT_ID` the project where your Apigee organization is located
- `APIGEE_ENV` the Apigee environment where the demo resources should be created
- `APIGEE_HOST` the Apigee host URL (please include protocol, such as https://my.apigeedomain.com)
- `KYC_MATCH_TARGET_SERVER_URI` the URI (without http or https) to your KYC Match backend
- `KYC_MATCH_TARGET_SERVER_PATH` the path to your SIM Swap backend such as "/myKycMatch/system"

Now source the `env.sh` file

```bash
source ./env.sh
```

3. Simply deploy the assets with the following command

```bash
./deploy-kyc-match.sh
```

The deployment script will create the proxy.

## Verify the setup

Feel free to navigate to the Google Cloud Console Apigee for verifying the created proxy. Generate sample calls towards the proxy, with access tokens generated from the CAMARA approved methods.

## Cleanup

If you want to clean up the artifacts from this example in your Apigee Organization, first source your `env.sh` script, and then run

```bash
./clean-up-kyc-match.sh
```
