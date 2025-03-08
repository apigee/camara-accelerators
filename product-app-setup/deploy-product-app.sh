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
# Pre-Setup: Environment Checks, Auxiliary functions and Tool Installation
# ==============================================================================

PRODUCT_NAME=camara-apiproduct-all-apis
DEVELOPER_NAME=camara-developer
DEVELOPER_EMAIL="${DEVELOPER_NAME}@acme.com"
SCOPES="kyc-match:match,openid,sim-swap,sim-swap:check,sim-swap:retrieve-date"

# Check for required environment variables
check_env_var() {
  var_name="$1"
  if [ -z "${!var_name}" ]; then
    echo "Error: Environment variable $var_name is not set."
    exit 1
  fi
}

create_apiproduct() {
  local product_name=$1
  local ops_file="./configuration-data/camara-ops.json"
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
  NUM_APPS=$(apigeecli apps get --name "${app_name}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq -r .'| length')
  if [[ $NUM_APPS -lt 2 ]]; then
    mapfile -t KEYPAIR < <(apigeecli apps create --name "${app_name}" --email "${developer}" --prods "${product_name}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq -r ".credentials[0] | .consumerKey,.consumerSecret")
  else
    # must not echo here, it corrupts the return value of the function.
    # printf "  The app %s already exists!\n" ${app_name}
    mapfile -t KEYPAIR < <(apigeecli apps get --name "${app_name}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq -r ".[0].credentials[0] | .consumerKey,.consumerSecret")
  fi
  echo "${KEYPAIR[@]}"
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
# Config Setup: API Product and App Creation
# ==============================================================================

echo "Configuring Apigee Artifacts..."

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


echo "Checking and possibly Creating Developer App"
# shellcheck disable=SC2046,SC2162
IFS=$' ' read -a CLIENT_CREDS <<<$(create_app "${PRODUCT_NAME}" "${DEVELOPER_EMAIL}")

echo " "
echo "All the Apigee artifacts are successfully deployed."
echo " "
echo "Copy/paste these statements into cloud shell to set variables for the"
echo "API Keys and secrets."
echo " "
echo "  CLIENT_ID=${CLIENT_CREDS[0]}"
echo ""
echo "  CLIENT_SECRET=${CLIENT_CREDS[1]}"
echo " "
echo " "
echo "-----------------------------"


