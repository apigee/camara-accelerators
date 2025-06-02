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

if [ -z "$PROJECT_ID" ]; then
  echo "No PROJECT_ID variable set"
  exit
fi

if [ -z "$REGION" ]; then
  echo "No REGION variable set"
  exit
fi

echo "Enabling APIs..."

gcloud config set project $PROJECT_ID
gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com 
# gcloud services enable iap.googleapis.com

echo "Building and deploying app..."

if [[ -z "${ARTIFACT_REGISTRY_ID}" ]]; then
  echo "Creating/checking banking-repo Docker registry..."

  ARTIFACT_REGISTRY_ID=${REGION}-docker.pkg.dev/${PROJECT_ID}/banking-repo

  repo_exists=$(gcloud artifacts repositories list \
  --location="${REGION}" \
  --project="${PROJECT_ID}" \
  --filter="name:projects/${PROJECT_ID}/locations/${REGION}/repositories/banking-repo" \
  --format="value(name)")

  if [[ -z "${repo_exists}" ]]; then
    echo "Repository ${ARTIFACT_REGISTRY_ID} does not exist. Creating it..."
     gcloud artifacts repositories create banking-repo --repository-format=docker \
        --location=${REGION} --description="Docker repository" \
        --project=${PROJECT_ID}
    if [[ $? -eq 0 ]]; then
        echo "Repository ${ARTIFACT_REGISTRY_ID} created successfully."
    else
        echo "Error creating repository ${ARTIFACT_REGISTRY_ID}."
        exit 1
    fi
  
  else
    echo "Repository ${ARTIFACT_REGISTRY_ID} already exists. Skipping creation."
    fi

else
  echo "Provided docker registry ${ARTIFACT_REGISTRY_ID}. Using it..."
fi

echo "Making sure Cloud Build has the right permissions for pushing the container to the registry..."
PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format='value(projectNumber)')
COMPUTE_ENGINE_DEFAULT_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"
echo "Your Compute Engine Default Service Account is: ${COMPUTE_ENGINE_DEFAULT_SA}"

# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#     --member="serviceAccount:${COMPUTE_ENGINE_DEFAULT_SA}" \
#     --role="roles/artifactregistry.writer"

# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#     --member="serviceAccount:${COMPUTE_ENGINE_DEFAULT_SA}" \
#     --role="roles/storage.objectViewer"

gcloud builds submit --region=${REGION} --tag ${ARTIFACT_REGISTRY_ID}/banking-app . 


gcloud run deploy banking-app \
  --image ${ARTIFACT_REGISTRY_ID}/banking-app \
  --region ${REGION} \
  --allow-unauthenticated \
  --update-env-vars="OAUTH_CLIENT_ID=FTSAyShwcOUzqhcggPC0GeKpnlf0u6Oy65ANkR5DlIZ2qgZs,\
  OAUTH_CLIENT_SECRET=h2YPQLD1cF5pv0MFCFYhet5J4aNl77oIdqhEXnsqQXA4In6KSG2wElL2ClSSYg8J,\
  OAUTH_AUTHORIZATION_ENDPOINT=https://dev.35.227.240.213.nip.io/v1/oauth20/authorize,\
  OAUTH_TOKEN_ENDPOINT=https://dev.35.227.240.213.nip.io/v1/oauth20/token,\
  OAUTH_REDIRECT_URI=https://banking-app-243779034093.us-central1.run.app/callback,\
  OAUTH_USERINFO_ENDPOINT=https://dev.35.227.240.213.nip.io/v1/oauth20/protected,\
  OAUTH_LOGOUT_ENDPOINT=https://dev.35.227.240.213.nip.io/v1/oauth20/logout,\
  APP_BASE_URL=https://banking-app-243779034093.us-central1.run.app,\
  SIM_SWAP_API_URL=https://dev.35.227.240.213.nip.io/camara/sim-swap/v1"