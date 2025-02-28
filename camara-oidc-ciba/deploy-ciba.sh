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


# ==============================================================================
# Pre-Setup: Environment Checks and Tool Installation
# ==============================================================================

# Check for required environment variables
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
check_env_var CLIENT_JWKS_URI
check_env_var CIBA_TARGET_SERVER_URI
check_env_var CIBA_TARGET_SERVER_PATH
check_env_var PRIVATE_KEY
check_env_var USE_MOCK

echo "Installing apigeecli..."
curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
export PATH="$PATH:$HOME/.apigeecli/bin"

# Get Google Cloud access token
TOKEN=$(gcloud auth print-access-token) || { echo "Error: Could not get Google Cloud access token."; exit 1; }
gcloud config set project "$APIGEE_PROJECT_ID" || { echo "Error: Could not set Google Cloud project."; exit 1; }


# ==============================================================================
# Placeholder Updates
# ==============================================================================

echo "Updating placeholders..."

PRE_PROP="# ciba.properties file
# JWT properties
issuer=$APIGEE_HOST
expiry=8h

#Authorization code properties
code=code

# token flow properties
grant_type=authorization_code
redirect_uri=https://localhost
jwks_uri=$CLIENT_JWKS_URI"
echo "$PRE_PROP" > ./apiproxy/resources/properties/ciba.properties || { echo "Error: Could not update ciba.properties"; exit 1; }

sed -i 's|#PATH_PLACEHOLDER#|'"${CIBA_TARGET_SERVER_PATH}"'|g' ./apiproxy/targets/default.xml || { echo "Error: Could not update default.xml"; exit 1; }

echo "Placeholders updated successfully."


# ==============================================================================
# Config Setup: Target Servers and KVMs
# ==============================================================================

echo "Creating necessary configs..."

echo "Creating CIBA target server..."
apigeecli targetservers create --name camara-oidc-ciba  --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --tls true --port 443 --host "$CIBA_TARGET_SERVER_URI" --token "$TOKEN" || { echo "Error: Could not create target server or it already exists. Proceeding with the setup..."; }
echo "Creation of Target Server done"

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


# ==============================================================================
# Apigee Proxy Setup and Deployment
# ==============================================================================

echo "Deploying Apigee artifacts..."

echo "Importing and Deploying Apigee camara-oidc-ciba-v1 proxy..."
REV=$(apigeecli apis create bundle -f ./apiproxy -n camara-oidc-ciba-v1 --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq ."revision" -r) || { echo "Error: Could not create Apigee proxy bundle. Output: $REV"; exit 1; }
apigeecli apis deploy --wait --name camara-oidc-ciba-v1 --ovr --rev "$REV" --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --token "$TOKEN" || { echo "Error: Could not deploy Apigee proxy."; exit 1; }

if [[ "$USE_MOCK" == "true" ]]; then
  echo "Using mock backend. Deploying mock proxy..."
  REV=$(apigeecli apis create bundle -f ./ciba-mock-backend/apiproxy -n camara-oidc-ciba-mock-backend-v1 --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq ."revision" -r) || { echo "Error: Could not create Apigee mock proxy bundle. Output: $REV"; exit 1; }
  apigeecli apis deploy --wait --name camara-oidc-ciba-mock-backend-v1 --ovr --rev "$REV" --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --token "$TOKEN" || { echo "Error: Could not deploy Apigee mock proxy."; exit 1; }
fi

echo "Deployment successful!"
