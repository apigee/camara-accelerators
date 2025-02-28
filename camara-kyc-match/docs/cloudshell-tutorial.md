# Deploy the CAMARA Know Your Customer (KYC) Match API

---

This sample proxy creates an implementation of the [CAMARA KYC Match](https://github.com/camaraproject/KnowYourCustomer). It validates the expected parameters as per the spec, validates the provided access token (to be retrieved using one of the supported CAMARA Authorization flows) and also validates the required scopes for each of the API operations. Descriptive errors are also created in scenarios where scopes don't match, parameters are invalid and so on.

Let's get started!

---

## Setup environment

Ensure you have an active GCP account selected in the Cloud shell

```sh
gcloud auth login
```

Navigate to the `camara-sim-swap` directory in the Cloud shell.

```sh
cd camara-kyc-match
```

Edit the provided sample `env.sh` file, and set the environment variables there.

Click <walkthrough-editor-open-file filePath="camara-kyc-match/env.sh">here</walkthrough-editor-open-file> to open the file in the editor

Then, source the `env.sh` file in the Cloud shell.

```sh
source ./env.sh
```

---

## Deploy Apigee components

Next, let's create and deploy the Apigee resources.

```sh
./deploy-kyc-match.sh
```

The deployment script will create the proxy and its assets.

Feel free to navigate to the Google Cloud Console Apigee for verifying the created proxy. Generate sample calls towards the proxy, generating client assertions and requests as per CAMARA OIDC requirements.

---

## Conclusion

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

Congratulations! You've successfully implemented deployed the OIDC core facade for CAMARA.

<walkthrough-inline-feedback></walkthrough-inline-feedback>

## Cleanup

If you want to clean up the artifacts from this example in your Apigee Organization, first source your `env.sh` script, and then run

```bash
./clean-up-kyc-match.sh
```
