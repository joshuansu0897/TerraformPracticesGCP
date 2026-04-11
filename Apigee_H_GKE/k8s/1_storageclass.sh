#!/bin/bash

# Configuration
export PROJECT_ID="my-default-project-483019"
export GCP_REGION_1="us-west1"
export GCP_REGION_2="us-central1"
export CLUSTER_1="apigee-cluster-us-west1"
export CLUSTER_2="apigee-cluster-us-central1"
export CERT_MANAGER_VERSION="v1.15.1"

echo "=== Bootstrapping Apigee prerequisites in ${CLUSTER_1} ==="
# Fetch credentials for region 1
gcloud container clusters get-credentials ${CLUSTER_1} --region ${GCP_REGION_1} --project ${PROJECT_ID}

# Create StorageClass YAML
cat <<EOF > ./storageclass.yaml
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: "apigee-sc"
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
  replication-type: none
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOF

# Apply StorageClass and set as default
kubectl apply -f ./storageclass.yaml
kubectl patch storageclass standard-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass apigee-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Install cert-manager
kubectl apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml

echo ""

echo "=== Bootstrapping Apigee prerequisites in ${CLUSTER_2} ==="
# Fetch credentials for region 2
gcloud container clusters get-credentials ${CLUSTER_2} --region ${GCP_REGION_2} --project ${PROJECT_ID}

# Apply StorageClass and set as default
kubectl apply -f ./storageclass.yaml
kubectl patch storageclass standard-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass apigee-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Install cert-manager
kubectl apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml

echo "Done! task 6 constraints implemented successfully across both clusters."
