# Deploy End-to-End sample

This sample implementation creates, with a single deployment script:

- Apigee API Proxy for SIM Swap functionality
- Apigee API Proxy as a SIM Swap mock backend (simulating a telco network)
- Relevant Apigee API Products, Apps and Dev, including scopes and keys that are specific to CAMARA
- A Mock Cloud Run app that simulates being a "mobile banking app". In this scenario, the banking app will use the Telco's SIM Swap business API to define if there's a risk to a transaction according to the status of the SIM Card of the mobile phone being used.

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
   - openssl

## (QuickStart) Setup using CloudShell

Use the following GCP CloudShell tutorial, and follow the instructions.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/apigee/camara-accelerators&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=sample-end-to-end/docs/cloudshell-tutorial.md)

## Setup instructions

1. Clone the Apigee CAMARA repo, and switch the camara-sim-swap directory

```bash
git clone https://github.com/apigee/camara-accelerators.git
cd camara-accelerators/sample-end-to-end
```

2. Edit the `env.sh` and configure the ENV vars

- `APIGEE_PROJECT_ID` the project where your Apigee organization is located
- `APIGEE_ENV` the Apigee environment where the demo resources should be created
- `APIGEE_HOST` the Apigee host URL (please DO NOT include protocol, leave that such as my.apigeedomain.com)

Now source the `env.sh` file

```bash
source ./env.sh
```

3. Simply deploy the assets with the following command

```bash
./deploy-end-to-end.sh
```

The deployment script will create all the assets. It can take a few minutes.

## Verify the setup

Feel free to navigate to the Google Cloud Console Apigee and verify the 3 proxies. Also open the Cloud Run app and execute a few transactions to see its behaviro.

## Cleanup

If you want to clean up the artifacts from this example in your Apigee Organization, first source your `env.sh` script, and then run

```bash
./clean-up-end-to-end.sh
```
