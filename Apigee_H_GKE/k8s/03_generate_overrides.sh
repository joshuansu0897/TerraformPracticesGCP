#!/bin/bash
# 3_generate_overrides.sh
# Dynamically generates overrides-dc-1.yaml and overrides-dc-2.yaml

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "============================================================"
echo "Generating Apigee Overrides for Multi-Region"
echo "Project ID: $PROJECT_ID"
echo "Region 1: $REGION_1 | Region 2: $REGION_2"
echo "============================================================"

generate_overrides() {
  local DC_NAME=$1
  local REGION=$2
  local ENV_NAME="prod-${REGION}"
  local FILENAME=$3

  cat <<EOF > "$SCRIPT_DIR/$FILENAME"
instanceID: "apigee-multi-region"
namespace: "$NAMESPACE"

gcp:
  projectID: "$PROJECT_ID"
  region: "$REGION"

k8sCluster:
  name: "apigee-cluster-${REGION}"
  region: "$REGION"

org: "$PROJECT_ID"

cassandra:
  hostNetwork: false
  datacenter: "$DC_NAME"
  rack: "ra-1"
  clusterName: "apigeecluster"
  replicaCount: 3

# Override default node selectors to match our Terraform-created node pool name
nodeSelector:
  requiredForScheduling: true
  apigeeRuntime:
    key: "cloud.google.com/gke-nodepool"
    value: "apigee-pool-apigee-cluster-${REGION}"
  apigeeData:
    key: "cloud.google.com/gke-nodepool"
    value: "apigee-pool-apigee-cluster-${REGION}"

logger:
  serviceAccountPath: "${PROJECT_ID}-apigee-logger.json"
metrics:
  serviceAccountPath: "${PROJECT_ID}-apigee-metrics.json"
mart:
  serviceAccountPath: "${PROJECT_ID}-apigee-mart.json"
synchronizer:
  serviceAccountPath: "${PROJECT_ID}-apigee-synchronizer.json"
udca:
  serviceAccountPath: "${PROJECT_ID}-apigee-udca.json"
watcher:
  serviceAccountPath: "${PROJECT_ID}-apigee-watcher.json"

virtualhosts:
  - name: "$ENV_GROUP_NAME"
    sslCertPath: "certs/cert-${ENV_GROUP_NAME}.pem"
    sslKeyPath: "certs/key-${ENV_GROUP_NAME}.pem"

envs:
  - name: "$ENV_NAME"
    serviceAccountPaths:
      synchronizer: "${PROJECT_ID}-apigee-synchronizer.json"
      udca: "${PROJECT_ID}-apigee-udca.json"
      runtime: "${PROJECT_ID}-apigee-runtime.json"
EOF
  echo "=> Generated $FILENAME for datacenter=$DC_NAME region=$REGION"
}

generate_overrides "dc-1" "$REGION_1" "overrides-dc-1.yaml"
generate_overrides "dc-2" "$REGION_2" "overrides-dc-2.yaml"

# Copy credentials into each chart directory so Helm's Files.Get can read them
echo "=> Copying credentials into Helm chart directories..."
CREDS_DIR="$SCRIPT_DIR/credentials"
HELM_ABS="$SCRIPT_DIR/$HELM_DIR"

# SA keys -> chart roots
cp "$CREDS_DIR/${PROJECT_ID}-apigee-logger.json"       "$HELM_ABS/apigee-telemetry/" 2>/dev/null || true
cp "$CREDS_DIR/${PROJECT_ID}-apigee-metrics.json"      "$HELM_ABS/apigee-telemetry/" 2>/dev/null || true
cp "$CREDS_DIR/${PROJECT_ID}-apigee-cassandra.json"    "$HELM_ABS/apigee-datastore/" 2>/dev/null || true
cp "$CREDS_DIR/${PROJECT_ID}-apigee-mart.json"         "$HELM_ABS/apigee-org/" 2>/dev/null || true
cp "$CREDS_DIR/${PROJECT_ID}-apigee-udca.json"         "$HELM_ABS/apigee-org/" 2>/dev/null || true
cp "$CREDS_DIR/${PROJECT_ID}-apigee-watcher.json"      "$HELM_ABS/apigee-org/" 2>/dev/null || true
cp "$CREDS_DIR/${PROJECT_ID}-apigee-synchronizer.json" "$HELM_ABS/apigee-env/" 2>/dev/null || true
cp "$CREDS_DIR/${PROJECT_ID}-apigee-udca.json"         "$HELM_ABS/apigee-env/" 2>/dev/null || true
cp "$CREDS_DIR/${PROJECT_ID}-apigee-runtime.json"      "$HELM_ABS/apigee-env/" 2>/dev/null || true

# TLS certs -> virtualhost chart
mkdir -p "$HELM_ABS/apigee-virtualhost/certs"
cp "$CREDS_DIR/cert-prod-envgroup.pem" "$HELM_ABS/apigee-virtualhost/certs/" 2>/dev/null || true
cp "$CREDS_DIR/key-prod-envgroup.pem"  "$HELM_ABS/apigee-virtualhost/certs/" 2>/dev/null || true

echo ""
echo "Note: overrides-dc-2.yaml does NOT yet contain 'multiRegionSeedHost'."
echo "      Script 6 will inject it after Region 1 is deployed."
echo "Done."
