#!/bin/bash
PROJECT_ID=$GOOGLE_CLOUD_PROJECT
ORG=$GOOGLE_CLOUD_PROJECT
ENV=test
ENV_GROUP=test-group
INGRESS_DN=${GOOGLE_CLOUD_PROJECT}-test.hybrid-apigee.net
GCP_REGION=${1:-us-central1}
GCP_ZONE=${2:-us-central1-a}

# ---  Validate environment variables - Tick/OK, Cross/Not OK
function statusCheck(){
  if [ -z "$1" ]
  then
    printf "\u274c $2=$1\n"
  else
    printf "\u2714 $2=$1\n"
  fi
}

# Call the function statusCheck to validate the environment
statusCheck "$PROJECT_ID" "PROJECT_ID"
statusCheck "$ORG" "ORG"
statusCheck "$ENV" "ENV"
statusCheck "$ENV_GROUP" "ENV_GROUP"
statusCheck "$INGRESS_DN" "INGRESS_DN"
statusCheck "$GCP_REGION" "GCP_REGION"
statusCheck "$GCP_ZONE" "GCP_ZONE"

# Update the compute environment
gcloud config set compute/region $GCP_REGION 
gcloud config set compute/zone  $GCP_ZONE
