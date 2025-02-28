# Deploy OIDC Core Frontend Facade for CAMARA Interoperability Profile

---

This sample proxy creates a facade layer for [OpenID Connect Core](https://openid.net/specs/openid-connect-core-1_0.html) frontend code flow that aims to comply with the [CAMARA Security and Interoperability Profile](https://github.com/camaraproject/IdentityAndConsentManagement/blob/main/documentation/CAMARA-Security-Interoperability.md). This API Proxy can be used in front of your IdP and it will enforce CAMARA requirements for CIBA such as request and client assertion parameters, scopes given to a certain client ID, validate JWT claims, validate login_hint and generate errors when the parameter don't match.

This specific sample mocks, internally, user login and user consent. You should update the redirect policies to redirect to your own IdP system.

Let's get started!

---

## Setup environment

Ensure you have an active GCP account selected in the Cloud shell

```sh
gcloud auth login
```

Navigate to the `product-app-setup` directory in the Cloud shell.

```sh
cd camara-oidc-core
```

Edit the provided sample `env.sh` file, and set the environment variables there.

Click <walkthrough-editor-open-file filePath="camara-oidc-core/env.sh">here</walkthrough-editor-open-file> to open the file in the editor

Then, source the `env.sh` file in the Cloud shell.

```sh
source ./env.sh
```

---

## Deploy Apigee components

Next, let's create and deploy the Apigee resources.

```sh
./deploy-oidc.sh
```

The deployment script will create the proxy and its property set. It won't have a target server - forwarding to a backend IdP and consent systems is mocked as "hardcoded" HTML pages within the proxy.

Feel free to navigate to the Google Cloud Console Apigee for verifying the created proxy. Generate sample calls towards the proxy, generating client assertions and requests as per CAMARA OIDC requirements.

---

## Conclusion

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

Congratulations! You've successfully implemented deployed the OIDC core facade for CAMARA.

<walkthrough-inline-feedback></walkthrough-inline-feedback>

## Cleanup

If you want to clean up the artifacts from this example in your Apigee Organization, first source your `env.sh` script, and then run

```bash
./clean-up-oidc.sh
```
