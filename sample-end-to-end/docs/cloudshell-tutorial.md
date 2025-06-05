# Deploy End to End sample

---

This is an utility sample that creates a sample [API Product](https://cloud.google.com/apigee/docs/api-platform/publish/what-api-product), [Developer](https://cloud.google.com/apigee/docs/api-platform/publish/adding-developers-your-api-product) and [Developer App](https://cloud.google.com/apigee/docs/api-platform/publish/creating-apps-surface-your-api) (including scopes to be used for other CAMARA samples in this repository) so you can easily test the CAMARA samples. It also deploys a sample Cloud Run app, mocking a banking client using CAMARA APIs, and 3 CAMARA samples (OIDC, SIM Swap and SIM Swap mock).

Let's get started!

---

## Setup environment

Ensure you have an active GCP account selected in the Cloud shell

```sh
gcloud auth login
```

Navigate to the `product-app-setup` directory in the Cloud shell.

```sh
cd sample-end-to-end
```

Edit the provided sample `env.sh` file, and set the environment variables there.

Click <walkthrough-editor-open-file filePath="sample-end-to-end/env.sh">here</walkthrough-editor-open-file> to open the file in the editor

Then, source the `env.sh` file in the Cloud shell.

```sh
source ./env.sh
```

---

## Deploy Apigee components

Next, let's create and deploy the Apigee resources.

```sh
./deploy-end-to-end.sh
```

This script creates an API Product, a developer and a developer app; 3 proxies and a Cloud Run App.

## Execute calls

Turn on the Apigee debug view for the 3 proxies (OIDC, SIM-Swap and SIM-Swap mock) and review the API product that was created.

Now, on Cloud Run, open the Web interface. Login with a mock user and after that, send a few transactions over 200 USD. Check the behavior of the proxies!

For a few transactions, we'll see (mocked) the SIM card was swapped just two recently and our app will block the transaction with this important insight from the telco!

---

## Conclusion

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

Congratulations! You've successfully implemented deployed the support assets for consuming the CAMARA APIs.

<walkthrough-inline-feedback></walkthrough-inline-feedback>

## Cleanup

If you want to clean up the artifacts from this example in your Apigee Organization, first source your `env.sh` script, and then run

```bash
./clean-up-end-to-end.sh
```
