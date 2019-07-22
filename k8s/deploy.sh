#!/bin/bash
set -e

# passive vars
GIT_COMMIT_SHA=$(git log -n 1 --pretty=format:"%H")
GIT_COMMIT_SHA_SHORT=$(git log -n 1 --pretty=format:"%h")
DEPLOY_SCRIPT_TIMESTAMP=$(date +"%s")
DEPLOY_SCRIPT_TIMESTAMP_PRETTY=$(date "+%H:%M:%S %m/%d/%Y")

# service specific vars
WORKSPACE_NAME=carrera
SERVICE_NAME=api
GCP_PROJECT_ID=devopspatterns
GCP_ZONE=us-central1-a
CLUSTER_NAME=hosting-applications

# derivative vars
DOCKER_REPOSITORY="gcr.io/${GCP_PROJECT_ID}"
TAG="${GIT_COMMIT_SHA}.${DEPLOY_SCRIPT_TIMESTAMP}"
DOCKER_SERVICE_TAG="${SERVICE_NAME}:${TAG}"
DEPLOYMENT_ANNOTATION="Git commit ${GIT_COMMIT_SHA_SHORT} deployed at ${DEPLOY_SCRIPT_TIMESTAMP_PRETTY} - ${DOCKER_IMAGE_TAG}"

# get cluster creds from gcloud
gcloud container clusters get-credentials $CLUSTER_NAME --zone $GCP_ZONE --project $GCP_PROJECT_ID

# docker build and tag
DOCKER_IMAGE_TAG="${DOCKER_REPOSITORY}/${DOCKER_SERVICE_TAG}"
#docker tag node:9.8-alpine $DOCKER_IMAGE_TAG
docker build -f ../Dockerfile -t $DOCKER_IMAGE_TAG .

# push
echo "pushing $DOCKER_IMAGE_TAG"
docker push $DOCKER_IMAGE_TAG

# compile manifests
#kustomize edit set image carrera-api:$(git log -n 1 --pretty=format:"%H")
cd base && kustomize edit set image carrera-api=$DOCKER_IMAGE_TAG && cd ..

# build and apply manifests
kustomize build base | kubectl apply -f -

