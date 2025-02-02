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


echo "Installing apigeecli..."
curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
export PATH="$PATH:$HOME/.apigeecli/bin"

# Get Google Cloud access token
TOKEN=$(gcloud auth print-access-token) || { echo "Error: Could not get Google Cloud access token."; exit 1; }
gcloud config set project "$APIGEE_PROJECT_ID" || { echo "Error: Could not set Google Cloud project."; exit 1; }


# ==============================================================================
# DELETE Actions
# ==============================================================================

echo "Undeploying ${PROXY_NAME} proxy"
REV=$(apigeecli envs deployments get --env "$APIGEE_ENV" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq --arg proxy_name "$PROXY_NAME" '.deployments[] | select(.apiProxy == $proxy_name).revision' -r)
apigeecli apis undeploy --name ${PROXY_NAME} --env "$APIGEE_ENV" --rev "$REV" --org "$APIGEE_PROJECT_ID" --token "$TOKEN"

echo "Deleting proxy ${PROXY_NAME} proxy"
apigeecli apis delete --name ${PROXY_NAME} --org "$APIGEE_PROJECT_ID" --token "$TOKEN"

echo "Undeployment finalized!"