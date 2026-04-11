#!/bin/bash
# 2_configure_gke_credentials.sh
# Fetches GKE credentials for local kubectl

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "============================================================"
echo "Configuring GKE Credentials for Apigee Multi-Region"
echo "Project: $PROJECT_ID"
echo "Region 1 Cluster: $CLUSTER_1 ($REGION_1)"
echo "Region 2 Cluster: $CLUSTER_2 ($REGION_2)"
echo "============================================================"

echo "=> Fetching credentials for Region 1 cluster..."
gcloud container clusters get-credentials ${CLUSTER_1} --region ${REGION_1} --project ${PROJECT_ID}

echo "=> Fetching credentials for Region 2 cluster..."
gcloud container clusters get-credentials ${CLUSTER_2} --region ${REGION_2} --project ${PROJECT_ID}

echo "=> Validating contexts:"
kubectl config get-contexts | grep apigee-cluster

echo ""
echo "Done! Credentials fetched successfully."
