#!/bin/bash
set -e

# passive vars
CWD=$( cd $(dirname "${BASH_SOURCE[0]}") && pwd )
GIT_COMMIT_SHA=$(git log -n 1 --pretty=format:"%H")
GIT_COMMIT_SHA_SHORT=$(git log -n 1 --pretty=format:"%h")
DEPLOY_SCRIPT_TIMESTAMP=$(date +"%s")
DEPLOY_SCRIPT_TIMESTAMP_PRETTY=$(date "+%H:%M:%S %m/%d/%Y")
BASE="$CWD/base"

# service specific vars
WORKSPACE_NAME=carrera
SERVICE_NAME=api
GCP_PROJECT=devopspatterns

# derivative vars
DOCKER_REPOSITORY="gcr.io/${GCP_PROJECT_ID}/"
TAG="${GIT_COMMIT_SHA}.${DEPLOY_SCRIPT_TIMESTAMP}"
DOCKER_SERVICE_TAG="${SERVICE_NAME}:${TAG}"
DEPLOYMENT_ANNOTATION="Git commit ${GIT_COMMIT_SHA_SHORT} deployed at ${DEPLOY_SCRIPT_TIMESTAMP_PRETTY} - ${DOCKER_IMAGE_TAG}"

# get cluster creds from gcloud
gcloud container clusters get-credentials hosting-applications --zone us-central1-a --project $GCP_PROJECT

# docker tag
DOCKER_IMAGE_TAG="${DOCKER_REPOSITORY}/${DOCKER_SERVICE_TAG}"
docker tag node:9.8-alpine $DOCKER_IMAGE_TAG

# push
gcloud docker -- push $DOCKER_IMAGE_TAG

# compile manifests
#kustomize edit set image carrera-api:$(git log -n 1 --pretty=format:"%H")
kustomize edit set image carrera-api=DOCKER_IMAGE_TAG

kustomize build base | kubectl apply -f -


# apply manifests
