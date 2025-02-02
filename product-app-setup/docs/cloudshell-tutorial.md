# Deploy Sample API Product, Developer and App for CAMARA Usage

---

This is an utility sample that creates a sample [API Product](https://cloud.google.com/apigee/docs/api-platform/publish/what-api-product), [Developer](https://cloud.google.com/apigee/docs/api-platform/publish/adding-developers-your-api-product) and [Developer App](https://cloud.google.com/apigee/docs/api-platform/publish/creating-apps-surface-your-api) (including scopes to be used for other CAMARA samples in this repository) so you can easily test the CAMARA samples.
The generated credentials can be used for generating assertions for the CAMARA authorization flows to be validated by Apigee.

Let's get started!

---

## Setup environment

Ensure you have an active GCP account selected in the Cloud shell

```sh
gcloud auth login
```

Navigate to the `product-app-setup` directory in the Cloud shell.

```sh
cd product-app-setup
```

Edit the provided sample `env.sh` file, and set the environment variables there.

Click <walkthrough-editor-open-file filePath="product-app-setup/env.sh">here</walkthrough-editor-open-file> to open the file in the editor

Then, source the `env.sh` file in the Cloud shell.

```sh
source ./env.sh
```

---

## Deploy Apigee components

Next, let's create and deploy the Apigee resources.

```sh
./deploy-product-app.sh
```

This script creates an API Product, a developer and a developer app. If successful, it will output the client_id and secret for you app.

Be sure to save the output for generating the client assertions for the CAMARA APIs later on.

You can also check the created assets in the Google Cloud Apigee UI.

---

## Conclusion

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

Congratulations! You've successfully implemented deployed the support assets for consuming the CAMARA APIs.

<walkthrough-inline-feedback></walkthrough-inline-feedback>

## Cleanup

If you want to clean up the artifacts from this example in your Apigee Organization, first source your `env.sh` script, and then run

```bash
./clean-up-product-app.sh
```
