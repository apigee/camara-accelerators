#!/bin/bash

# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



### Environment-set variables

check_env_var() {
  var_name="$1"
  if [ -z "${!var_name}" ]; then
    echo "Error: Environment variable $var_name is not set."
    exit 1
  fi
}

check_env_var APIGEE_PROJECT_ID
check_env_var APIGEE_ENV
check_env_var APIGEE_HOST

### Default variables
export REGION="us-central1"
export PROJECT_ID="${APIGEE_PROJECT_ID}"
export SIM_SWAP_API_URL="https://${APIGEE_HOST}/camara/sim-swap/v0"
export SIM_SWAP_TARGET_SERVER_URI="${APIGEE_HOST}" 
export SIM_SWAP_TARGET_SERVER_PATH="/camara-sim-swap-mock-backend"
export TARGET_SERVER_NAME="camara-sim-swap" # Target server name for sim-swap
export PRODUCT_NAME="camara-apiproduct-all-apis"
export DEVELOPER_NAME="camara-developer"
export DEVELOPER_EMAIL="${DEVELOPER_NAME}@acme.com"
export SCOPES="kyc-match:match,openid,profile,email,sim-swap,sim-swap:check,sim-swap:retrieve-date"
export BANKING_APP_URL=""


### Default Variables for the App
export OAUTH_AUTHORIZATION_ENDPOINT="https://${APIGEE_HOST}/camara/openIDConnectCore/v1/authorize"
export OAUTH_TOKEN_ENDPOINT="https://${APIGEE_HOST}/camara/openIDConnectCore/v1/token"
 

### Utility functions
create_apiproduct() {
  local product_name=$1
  local ops_file="./api/camara-ops.json"
  if apigeecli products get --name "${product_name}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check >>/dev/null 2>&1; then
    printf "  The apiproduct %s already exists!\n" "${product_name}"
  else
    [[ ! -f "$ops_file" ]] && printf "missing operations definition file %s\n" "$ops_file" && exit 1
    apigeecli products create --name "${product_name}" --display-name "${product_name}" \
      --opgrp "$ops_file" \
      --envs "$APIGEE_ENV" --approval auto -s "$SCOPES" \
      --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check
  fi
}

create_app() {
  local product_name=$1
  local developer=$2
  local app_name=${product_name}-app
  local KEYPAIR

  local NUM_APPS
  NUM_APPS=$(apigeecli apps get --name "${app_name}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq -r '.|length')
  if [[ $NUM_APPS -lt 2 ]]; then
    read -r -a KEYPAIR < <(apigeecli apps create --name "${app_name}" --email "${developer}" --prods "${product_name}" --callback "${BANKING_APP_URL}/callback" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq -r ".credentials[0] | [.consumerKey, .consumerSecret] | join(\" \")")
  else
    read -r -a KEYPAIR < <(apigeecli apps get --name "${app_name}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq -r ".[0].credentials[0] | [.consumerKey, .consumerSecret] | join(\" \")")
  fi
  echo "${KEYPAIR[@]}"
}


### Installing apigeecli

echo "Installing apigeecli..."
curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
export PATH="$PATH:$HOME/.apigeecli/bin"

# Get Google Cloud access token

gcloud config set project "$APIGEE_PROJECT_ID" || { echo "Error: Could not set Google Cloud project."; exit 1; }


### Setting up app
echo "Enabling APIs and Firestore"

gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable firestore.googleapis.com 

DEFAULT_DATABASE_EXISTS=$(gcloud firestore databases list --project "${PROJECT_ID}" --format="value(name)" | grep -E ".*/databases/\(default\)$")
if [ -z "$DEFAULT_DATABASE_EXISTS" ]; then
  echo "  Default Firestore database does not exist in project ${PROJECT_ID}."
  echo "  Attempting to create a default (Native mode) Firestore database in region ${REGION}..."
  # Note: Creating a database is a permanent choice for the project regarding Native vs Datastore mode for Firestore.
  # This script assumes Firestore Native mode is desired if no database exists.
  gcloud firestore databases create --database=\(default\) --project="${PROJECT_ID}" --location="${REGION}" --type=firestore-native --quiet || {
    echo "Error: Failed to create default Firestore database (Native mode) in region ${REGION} for project ${PROJECT_ID}."
    echo "This could be due to various reasons, including an existing Datastore mode database or insufficient permissions."
    echo "Please check the project settings or create it manually via the Google Cloud Console."
    exit 1
  }
  echo "  Default Firestore database (Native mode) created successfully in region ${REGION}."
else
  echo "  Default Firestore database already exists."
fi


PRIVATE_KEY=$(openssl genpkey -algorithm RSA -outform PEM -pkeyopt rsa_keygen_bits:2048)

echo "Deploying Banking App..."

# gcloud run deploy --source . will use Cloud Build to build the image and then deploy it.
gcloud run deploy banking-app-v2 \
  --source ./src/ \
  --region ${REGION} \
  --allow-unauthenticated --quiet 

BANKING_APP_URL=$(gcloud run services describe banking-app-v2 \
      --platform="managed" \
      --region="${REGION}" \
      --format="value(status.url)")

if [ -z "$BANKING_APP_URL" ]; then
    echo "ERROR: Failed to fetch service URL for banking app."
    exit 1
fi

TOKEN=$(gcloud auth print-access-token) || { echo "Error: Could not get Google Cloud access token."; exit 1; }

echo "Creating env-scoped KVM and KVM Entry for Private Key..."
apigeecli kvms create --name camara-oidc-ciba  --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV"  --token "$TOKEN" || { echo "Error: Could not create KVM or it already exists. Proceeding with the setup..."; }

if apigeecli kvms entries create -m camara-oidc-ciba -k "id_token_private_key" --value "${PRIVATE_KEY}" --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV"  --token "$TOKEN" 
then 
 echo "KVM Entry created successfully" 
else 
  ret=$?
  if [[ $ret -eq 409 ]]; then
    echo "Warning: KVM Entry 'id_token_private_key' already exists.  Continuing..."
  else
    echo "Error: Could not create KVM entry. Error code: $ret. Exiting..."
    exit 1
  fi
fi

TOKEN=$(gcloud auth print-access-token) || { echo "Error: Could not get Google Cloud access token."; exit 1; }


echo "Creating API Product...."
create_apiproduct "$PRODUCT_NAME"


printf "Creating Developer %s\n" "${DEVELOPER_EMAIL}"
if apigeecli developers get --email "${DEVELOPER_EMAIL}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check >>/dev/null 2>&1; then
  printf "  The developer already exists.\n"
else
  apigeecli developers create --user "${DEVELOPER_EMAIL}" --email "${DEVELOPER_EMAIL}" \
    --first Camara --last SampleDeveloper \
    --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check
fi


echo "Creating Developer App"
# shellcheck disable=SC2046,SC2162
IFS=$' ' read -a CLIENT_CREDS <<<$(create_app "${PRODUCT_NAME}" "${DEVELOPER_EMAIL}")

CLIENT_ID=${CLIENT_CREDS[0]}
CLIENT_SECRET=${CLIENT_CREDS[1]}

echo "CLIENT_ID: $CLIENT_ID"
echo "SECRET: $CLIENT_SECRET"

### Deploy OIDC Proxy

PRE_PROP="# ciba.properties file
# JWT properties
issuer=$APIGEE_HOST
expiry=8h"

echo "$PRE_PROP" > ./api/oidc/apiproxy/resources/properties/oidc.properties || { echo "Error: Could not update properties"; exit 1; }

TOKEN=$(gcloud auth print-access-token) || { echo "Error: Could not get Google Cloud access token."; exit 1; }

echo "Importing and Deploying Apigee camara-oidc-v1 proxy..."
REV=$(apigeecli apis create bundle -f ./api/oidc/apiproxy -n camara-oidc-v1 --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq ."revision" -r) || { echo "Error: Could not create Apigee proxy bundle. Output: $REV"; exit 1; }
apigeecli apis deploy --wait --name camara-oidc-v1 --ovr --rev "$REV" --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --token "$TOKEN" || { echo "Error: Could not deploy Apigee proxy."; exit 1; }


echo "Deployment successful!"


### Deploy Sim-swap proxy and mock


sedi_args=("-i")
if [[ "$(uname)" == "Darwin" ]]; then
  sedi_args=("-i" "") # For macOS, sed -i requires an extension argument. "" means no backup.
fi

sed "${sedi_args[@]}" 's|#PATH_PLACEHOLDER#|'"${SIM_SWAP_TARGET_SERVER_PATH}"'|g' ./api/sim-swap/apiproxy/targets/default.xml || { echo "Error: Could not update default.xml"; exit 1; }

TOKEN=$(gcloud auth print-access-token) || { echo "Error: Could not get Google Cloud access token."; exit 1; }

apigeecli targetservers create --name ${TARGET_SERVER_NAME}  --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --tls true --port 443 --host "${SIM_SWAP_TARGET_SERVER_URI}" --token "$TOKEN" || { echo "Error: Could not create target server or it already exists. Proceeding with the setup..."; }


echo "Importing and Deploying Apigee camara-sim-swap-v1 proxy..."
REV=$(apigeecli apis create bundle -f ./api/sim-swap/apiproxy -n camara-sim-swap-v1 --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq ."revision" -r) || { echo "Error: Could not create Apigee proxy bundle. Output: $REV"; exit 1; }
apigeecli apis deploy --wait --name camara-sim-swap-v1 --ovr --rev "$REV" --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --token "$TOKEN" || { echo "Error: Could not deploy Apigee proxy."; exit 1; }

echo "Using mock backend. Deploying camara-sim-swap-mock-backend proxy..."
  REV=$(apigeecli apis create bundle -f ./api/sim-swap/sim-swap-mock-backend/apiproxy -n camara-sim-swap-mock-backend --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq ."revision" -r) || { echo "Error: Could not create Apigee mock proxy bundle. Output: $REV"; exit 1; }
  apigeecli apis deploy --wait --name camara-sim-swap-mock-backend --ovr --rev "$REV" --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --token "$TOKEN" || { echo "Error: Could not deploy Apigee mock proxy."; exit 1; }

TOKEN=$(gcloud auth print-access-token) || { echo "Error: Could not get Google Cloud access token."; exit 1; }


# Re-deploy Cloud run with new variables, and reload
echo "Redeploying Banking App with new environment variables..."
gcloud run deploy banking-app-v2 \
  --source ./src/ \
  --region ${REGION} \
  --allow-unauthenticated \
  --set-env-vars="OAUTH_AUTHORIZATION_ENDPOINT=${OAUTH_AUTHORIZATION_ENDPOINT},\
OAUTH_TOKEN_ENDPOINT=${OAUTH_TOKEN_ENDPOINT},\
SIM_SWAP_API_URL=${SIM_SWAP_API_URL},\
OAUTH_REDIRECT_URI=${BANKING_APP_URL}/callback,\
OAUTH_CLIENT_ID=${CLIENT_ID},\
OAUTH_CLIENT_SECRET=${CLIENT_SECRET}, \
FLASK_SECRET_KEY=super-secret-key" --quiet
