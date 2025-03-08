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


# Required: Target Server URI for KYC-MATCH.
#  "https://" will be prepended.  Use the same value as APIGEE_HOST 
#  if using the mock backend.
export KYC_MATCH_TARGET_SERVER_URI="KYC-MATCH_TARGET_SERVER_URI" 

# Required: Path added to KYC-MATCH_TARGET_SERVER_URI (e.g., "/KYC-MATCH/backend").
#  Can be empty string. If using the mock backend, use "/camara-kyc-match-mock-backend".
export KYC_MATCH_TARGET_SERVER_PATH="" 

# Required: Use mock backend? ("true" or "false").
# Deploys a mock Apigee proxy for simulating simswap response.
# export USE_MOCK="true"