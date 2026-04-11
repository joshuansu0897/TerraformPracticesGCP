#!/bin/bash
# 7_deploy_region_2_components.sh
# Deploys ALL Apigee Hybrid components to Region 2.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

OVERRIDES_FILE="$SCRIPT_DIR/overrides-dc-2.yaml"

echo "============================================================"
echo "Deploying Apigee Hybrid to Region 2 ($REGION_2)"
echo "Context: $CONTEXT_2"
echo "============================================================"

if [[ ! -f "$OVERRIDES_FILE" ]]; then
  echo "Error: $OVERRIDES_FILE not found."
  exit 1
fi

if ! grep -q "multiRegionSeedHost" "$OVERRIDES_FILE"; then
    echo "CRITICAL: multiRegionSeedHost missing from $OVERRIDES_FILE!"
    echo "Did you skip script 6_multi_region_sync.sh?"
    exit 1
fi

kubectl config use-context "$CONTEXT_2"

echo "=> Installing Apigee CRDs..."
kubectl apply -k "$SCRIPT_DIR/$HELM_DIR/apigee-operator/etc/crds/default/" \
  --server-side \
  --force-conflicts \
  --validate=false

echo "=> Installing Apigee Operator..."
helm upgrade operator "$SCRIPT_DIR/$HELM_DIR/apigee-operator" \
  --install \
  --namespace $NAMESPACE --create-namespace \
  --atomic -f "$OVERRIDES_FILE"

echo "=> Installing Apigee Datastore (Cassandra with seedHost)..."
helm upgrade datastore "$SCRIPT_DIR/$HELM_DIR/apigee-datastore" \
  --install \
  --namespace $NAMESPACE \
  --atomic -f "$OVERRIDES_FILE"

echo "=> Installing Apigee Telemetry..."
helm upgrade telemetry "$SCRIPT_DIR/$HELM_DIR/apigee-telemetry" \
  --install \
  --namespace $NAMESPACE \
  --atomic -f "$OVERRIDES_FILE"

echo "=> Installing Apigee Redis..."
helm upgrade redis "$SCRIPT_DIR/$HELM_DIR/apigee-redis" \
  --install \
  --namespace $NAMESPACE \
  --atomic -f "$OVERRIDES_FILE"

echo "=> Installing Apigee Ingress Manager..."
helm upgrade ingress-manager "$SCRIPT_DIR/$HELM_DIR/apigee-ingress-manager" \
  --install \
  --namespace $NAMESPACE \
  --atomic -f "$OVERRIDES_FILE"

echo "=> Installing Apigee Organization ($PROJECT_ID)..."
helm upgrade "$PROJECT_ID" "$SCRIPT_DIR/$HELM_DIR/apigee-org" \
  --install \
  --namespace $NAMESPACE \
  --atomic -f "$OVERRIDES_FILE"

echo "=> Installing Apigee Environment ($ENV_NAME_2)..."
helm upgrade "$ENV_NAME_2" "$SCRIPT_DIR/$HELM_DIR/apigee-env" \
  --install \
  --namespace $NAMESPACE \
  --atomic \
  --set "env=$ENV_NAME_2" \
  -f "$OVERRIDES_FILE"

echo "=> Installing Apigee Virtualhost ($ENV_GROUP_NAME)..."
helm upgrade "apigee-virtualhost-${ENV_GROUP_NAME}" "$SCRIPT_DIR/$HELM_DIR/apigee-virtualhost" \
  --install \
  --namespace $NAMESPACE \
  --atomic \
  --set "envgroup=$ENV_GROUP_NAME" \
  -f "$OVERRIDES_FILE"

echo ""
echo "Done! Region 2 components installed."
echo "Next: Run 8_cassandra_data_replication.sh"
