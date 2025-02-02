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

PROXY_NAME=camara-oidc-v1

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
expiry=8h"

echo "$PRE_PROP" > ./apiproxy/resources/properties/oidc.properties || { echo "Error: Could not update properties"; exit 1; }

echo "Placeholders updated successfully."



# ==============================================================================
# Apigee Proxy Setup and Deployment
# ==============================================================================

echo "Deploying Apigee artifacts..."

echo "Importing and Deploying Apigee ${PROXY_NAME} proxy..."
REV=$(apigeecli apis create bundle -f ./apiproxy -n ${PROXY_NAME} --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq ."revision" -r) || { echo "Error: Could not create Apigee proxy bundle. Output: $REV"; exit 1; }
apigeecli apis deploy --wait --name ${PROXY_NAME} --ovr --rev "$REV" --org "$APIGEE_PROJECT_ID" --env "$APIGEE_ENV" --token "$TOKEN" || { echo "Error: Could not deploy Apigee proxy."; exit 1; }


echo "Deployment successful!"
