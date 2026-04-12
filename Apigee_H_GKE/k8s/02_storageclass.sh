#!/bin/bash

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "=== Bootstrapping Apigee prerequisites in ${CLUSTER_1} ==="

kubectl config use-context "$CONTEXT_1"
  
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

kubectl config use-context "$CONTEXT_2"

# Apply StorageClass and set as default
kubectl apply -f ./storageclass.yaml
kubectl patch storageclass standard-rwo -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass apigee-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Install cert-manager
kubectl apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.yaml

echo "Done! storage class and cert-manager setup completed in both clusters."
