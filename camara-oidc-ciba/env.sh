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

# Required: Apigee Project ID.
export APIGEE_PROJECT_ID="APIGEE_PROJECT_ID_TO_SET"

# Required: Apigee Host URL (include protocol, e.g., https://api.mydomain.com).
export APIGEE_HOST="APIGEE_HOST_TO_SET" 

# Required: Apigee Environment (e.g., dev, prod, test).
export APIGEE_ENV="APIGEE_ENV_TO_SET" 

# Required: URI for the JWKS used to sign client assertions 
# (e.g., https://token.dev/jwks/keys.json).
export CLIENT_JWKS_URI="CLIENT_JWKS_URI" 

# Required: Target Server URI for CIBA requests (e.g., "consent.com").
#  "https://" will be prepended.  Use the same value as APIGEE_HOST 
#  if using the mock backend.
export CIBA_TARGET_SERVER_URI="CIBA_TARGET_SERVER_URI" 

# Required: Path added to CIBA_TARGET_SERVER_URI (e.g., "/idp/consent").
#  Can be empty string. If using the mock backend, use "/camara-oidc-ciba-bknd-mock".
export CIBA_TARGET_SERVER_PATH="/camara-oidc-ciba-bknd-mock" 

# Required: Private Key used by Apigee to sign the final ID token.
# Format: "PEM FORMAT"
export PRIVATE_KEY="" 

# Required: Use mock backend? ("true" or "false").
# Deploys a mock Apigee proxy for simulating backend user approval.
export USE_MOCK="true"