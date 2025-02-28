# Deploy Sample API Product, Developer and App for CAMARA Usage

This is an utility sample that creates a sample [API Product](https://cloud.google.com/apigee/docs/api-platform/publish/what-api-product), [Developer](https://cloud.google.com/apigee/docs/api-platform/publish/adding-developers-your-api-product) and [Developer App](https://cloud.google.com/apigee/docs/api-platform/publish/creating-apps-surface-your-api) (including scopes to be used for other CAMARA samples in this repository) so you can easily test the CAMARA samples.
The generated credentials can be used for generating assertions for the CAMARA authorization flows to be validated by Apigee.

## Screencast

TBD

## Prerequisites

1. [Provision Apigee X](https://cloud.google.com/apigee/docs/api-platform/get-started/provisioning-intro)
2. Access to create and delete Apigee API Products, Apps & Developers
3. Configure [external access](https://cloud.google.com/apigee/docs/api-platform/get-started/configure-routing#external-access) for API traffic to your Apigee X instance
4. Make sure the following tools are available in your terminal's $PATH (Cloud Shell has these pre-configured)
   - [gcloud SDK](https://cloud.google.com/sdk/docs/install)
   - unzip
   - curl
   - jq
   - npm

## (QuickStart) Setup using CloudShell

Use the following GCP CloudShell tutorial, and follow the instructions.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/carlosmscabral/apigee-camara-staging&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=product-app-setup/docs/cloudshell-tutorial.md)

## Setup instructions

1. Clone the Apigee CAMARA repo, and switch the product-app-setup directory

```bash
git clone https://github.com/carlosmscabral/apigee-camara-staging.git
cd apigee-camara-staging/product-app-setup
```

2. Edit the `env.sh` and configure the ENV vars

- `APIGEE_PROJECT_ID` the project where your Apigee organization is located
- `APIGEE_ENV` the Apigee environment where the demo resources should be created

Now source the `env.sh` file

```bash
source ./env.sh
```

3. Simply deploy the assets with the following command

```bash
./deploy-product-app.sh
```

If successful, the script will output the client_id and secret. Be sure to hold those for generating your client assertions.

## Verify the setup

Feel free to navigate to the Google Cloud Console Apigee pages for Apps, API Products and Developers to see the created assets and their basic configuration.

## Cleanup

If you want to clean up the artifacts from this example in your Apigee Organization, first source your `env.sh` script, and then run

```bash
./clean-up-product-app.sh
```
