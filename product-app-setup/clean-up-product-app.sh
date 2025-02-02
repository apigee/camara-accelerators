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



PRODUCT_NAME=camara-apiproduct-all-apis
DEVELOPER_NAME=camara-developer
DEVELOPER_EMAIL="${DEVELOPER_NAME}@acme.com"

# ==============================================================================
# Pre-Setup: Environment Checks, Auxiliary functions and Tool Installation
# ==============================================================================


# Check for required environment variables
check_env_var() {
  var_name="$1"
  if [ -z "${!var_name}" ]; then
    echo "Error: Environment variable $var_name is not set."
    exit 1
  fi
}

delete_product() {
  local product_name=$1
  if apigeecli products get --name "${product_name}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check >>/dev/null 2>&1; then
    printf "Deleting API Product %s\n" "${product_name}"
    apigeecli products delete --name "${product_name}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check
  else
    printf "  The apiproduct %s does not exist.\n" "${product_name}"
  fi
}

delete_app() {
  local developer_id=$1
  local app_name=$2
  printf "Checking Developer App %s\n" "${app_name}"
  local NUM_APPS
  NUM_APPS=$(apigeecli apps get --name "${app_name}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq -r .'| length')
  if [[ $NUM_APPS -eq 1 ]]; then
    printf "Deleting Developer App %s\n" "${app_name}"
    apigeecli apps delete --id "${developer_id}" --name "${app_name}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN"
  else
    printf "  The app %s does not exist for developer %s.\n" "${app_name}" "${developer_id}"
  fi
}

delete_developer() {
  local developer_email=$1
  if apigeecli developers get --email "${developer_email}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check >>/dev/null 2>&1; then
    apigeecli developers delete --email "${developer_email}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check
  else
    printf "  The developer %s does not exist.\n" "${developer_email}"
  fi
}

check_env_var APIGEE_PROJECT_ID
check_env_var APIGEE_ENV

TOKEN=$(gcloud auth print-access-token)

echo "Installing apigeecli"
curl -s https://raw.githubusercontent.com/apigee/apigeecli/main/downloadLatest.sh | bash
export PATH=$PATH:$HOME/.apigeecli/bin

printf "Checking Developer %s\n" "${DEVELOPER_EMAIL}"
if apigeecli developers get --email "${DEVELOPER_EMAIL}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check >>/dev/null 2>&1; then
  echo "Checking Developer Apps"
  DEVELOPER_ID=$(apigeecli developers get --email "${DEVELOPER_EMAIL}" --org "$APIGEE_PROJECT_ID" --token "$TOKEN" --disable-check | jq -r .'developerId')
  delete_app "$DEVELOPER_ID" "$PRODUCT_NAME-app"


  echo "Deleting Developer"
  delete_developer "${DEVELOPER_EMAIL}"
else
  printf "  The developer %s does not exist.\n" "${DEVELOPER_EMAIL}"
fi

echo "Checking API Products"
delete_product "${PRODUCT_NAME}"


echo " "
echo "All the Apigee artifacts should have been removed."
echo " "