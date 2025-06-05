# Apigee Samples for Open Gateway/CAMARA APIs

- [Apigee Samples for Open Gateway/CAMARA APIs](#apigee-samples-for-open-gatewaycamara-apis)
  - [Intro](#intro)
    - [Audience](#audience)
  - [Before you begin](#before-you-begin)
  - [Using the sample proxies](#using-the-sample-proxies)
    - [Samples](#samples)
  - [Modifying a sample proxy](#modifying-a-sample-proxy)
  - [Ask questions on the Community Forum](#ask-questions-on-the-community-forum)
  - [Apigee documentation](#apigee-documentation)
  - [Contributing](#contributing)
  - [License](#license)
  - [Not Google Product Clause](#not-google-product-clause)
  - [Support](#support)

---

## <a name="intro"></a>Intro

This repository provides a collection of sample API proxies tailored for [Open Gateway/CAMARA APIs](https://github.com/camaraproject), designed to be deployed and run on Apigee X or [hybrid](https://cloud.google.com/apigee/docs/hybrid/latest/what-is-hybrid).

These samples offer a starting point for developers looking to design and implement Apigee API proxies that adhere to the [Open Gateway/CAMARA](https://github.com/camaraproject) specifications.

### <a name="who"></a>Audience

This repository is intended for [Apigee](https://cloud.google.com/apigee) API proxy developers, or those interested in learning how to develop APIs that run on Apigee X & hybrid, specifically for Open Gateway/CAMARA APIs. A basic understanding of Apigee and how to create simple API proxies is assumed. If you're new to Apigee, we recommend this [getting started tutorial](https://cloud.google.com/apigee/docs/api-platform/get-started/get-started).

## <a name="before"></a>Before you begin

1.  Review the complete list of [Prerequisites](https://cloud.google.com/apigee/docs/api-platform/get-started/prerequisites) for installing Apigee.

2.  You'll need access to a Google Cloud Platform account and project. [Sign up for a free GCP trial account.](https://console.cloud.google.com/freetrial)

3.  If you don't already have one, provision an Apigee instance. [Create a free Apigee eval instance.](https://apigee.google.com/setup/eval)

4.  Clone this project from GitHub to your local system.

## <a name="using"></a>Using the sample proxies

Developers can begin by browsing the available samples, based on the specific Open Gateway/CAMARA API or use case. All sample proxies are located in the root folder.

### <a name="samples"></a>Samples

|     | Sample                                 | Description                                                  | Cloud Shell Tutorial                                                                                                                                                                                                                                                                                                     |
| --- | -------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | [product-app-setup](product-app-setup) | Sample utility for dev, app and API Product creation.        | [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/carlosmscabral/apigee-camara-staging&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=product-app-setup/docs/cloudshell-tutorial.md) |
| 2   | [camara-kyc-match](camara-kyc-match)   | Reference implementation for the KYC Match API.              | [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/carlosmscabral/apigee-camara-staging&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=camara-kyc-match/docs/cloudshell-tutorial.md)  |
| 3   | [camara-sim-swap](camara-sim-swap)     | Reference implementation for the SIM Swap API.               | [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/carlosmscabral/apigee-camara-staging&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=camara-sim-swap/docs/cloudshell-tutorial.md)   |
| 4   | [camara-oidc-core](camara-oidc-core)   | Reference implementation of the Frontend OIDC Auth flow.     | [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/carlosmscabral/apigee-camara-staging&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=camara-oidc-core/docs/cloudshell-tutorial.md)  |
| 5   | [camara-oidc-ciba](camara-oidc-ciba)   | Reference implementation of the Backend CIBA OIDC Auth flow. | [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/carlosmscabral/apigee-camara-staging&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=camara-oidc-ciba/docs/cloudshell-tutorial.md)  |
| 6   | [Sample End-to-End](sample-end-to-end) | Full sample with OIDC, Product/Apps, Sim-Swap and Mock       | [![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.png)](https://ssh.cloud.google.com/cloudshell/open?cloudshell_git_repo=https://github.com/carlosmscabral/apigee-camara-staging&cloudshell_git_branch=main&cloudshell_workspace=.&cloudshell_tutorial=sample-end-to-end/docs/cloudshell-tutorial.md) |

## <a name="modifying"></a>Modifying a sample proxy

You are welcome to modify and extend these sample proxies. Changes can be made in the Apigee [management UI](https://cloud.google.com/apigee/docs/api-platform/develop/ui-edit-proxy) or using the Cloud Code [extension for local development](https://cloud.google.com/apigee/docs/api-platform/local-development/setup) in Visual Studio Code. Choose the method that is most convenient for you.

Redeploy the proxies for any changes to be applied.

## <a name="ask"></a>Ask questions on the Community Forum

For questions or answers related to developing API proxies, visit [The Apigee Forum](https://www.googlecloudcommunity.com/gc/Apigee/bd-p/cloud-apigee) on the [Google Cloud Community site](https://www.googlecloudcommunity.com/).

## <a name="docs"></a>Apigee documentation

The official Apigee documentation can be found [here](https://cloud.google.com/apigee/docs).

## <a name="contributing"></a>Contributing

Please add any new samples as a new folder at the root level of the repository.

For more information on how to contribute, please read the [guidelines](./CONTRIBUTING.md).

## License

All solutions within this repository are licensed under the [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) license. See the [LICENSE](./LICENSE.txt) file for the full terms and conditions.

## Not Google Product Clause

This is not an officially supported Google product, nor is it part of any official Google product.

## Support

For support or assistance, please consult the [Google Cloud Community forum dedicated to Apigee](https://www.googlecloudcommunity.com/gc/Apigee/bd-p/cloud-apigee).
