#!/bin/bash

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "=== Bootstrapping Apigee prerequisites in ${CLUSTER_1} ==="
# Fetch credentials for region 1
gcloud container clusters get-credentials ${CLUSTER_1} --region ${REGION_1} --project ${PROJECT_ID}

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
gcloud container clusters get-credentials ${CLUSTER_2} --region ${REGION_2} --project ${PROJECT_ID}

# Apply StorageClass and set as default
kubectl apply -f ./storageclass.yaml
kubectl patch storageclass standard-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass apigee-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Install cert-manager
kubectl apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml

echo "Done! task 6 constraints implemented successfully across both clusters."
