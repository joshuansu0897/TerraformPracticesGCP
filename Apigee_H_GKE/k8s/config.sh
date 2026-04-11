#!/bin/bash
# config.sh - Shared configuration for all Apigee multi-region deployment scripts.
# These values must match the Terraform configuration.

# Ensure tools are on PATH
export PATH="/Users/joshuansu0897/google-cloud-sdk/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

export PROJECT_ID="my-default-project-483019"
export REGION_1="us-west1"
export REGION_2="us-central1"
export DOMAIN_NAME="joshuansu.xyz"

export CLUSTER_1="apigee-cluster-${REGION_1}"
export CLUSTER_2="apigee-cluster-${REGION_2}"

export CONTEXT_1="gke_${PROJECT_ID}_${REGION_1}_${CLUSTER_1}"
export CONTEXT_2="gke_${PROJECT_ID}_${REGION_2}_${CLUSTER_2}"

export NAMESPACE="apigee"
export ENV_GROUP_NAME="prod-envgroup"
export ENV_NAME_1="prod-${REGION_1}"
export ENV_NAME_2="prod-${REGION_2}"

export HELM_DIR="./helm"
export CHART_VERSION="1.14.3"
export CHART_REPO="oci://us-docker.pkg.dev/apigee-release/apigee-hybrid-helm-charts"
