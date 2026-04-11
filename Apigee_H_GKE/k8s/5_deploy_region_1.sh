#!/bin/bash
# 5_deploy_region_1.sh
# Deploys full Apigee Hybrid stack to Region 1 cluster via Helm.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

OVERRIDES_FILE="$SCRIPT_DIR/overrides-dc-1.yaml"

echo "============================================================"
echo "Deploying Apigee Hybrid to Region 1 ($REGION_1)"
echo "Context: $CONTEXT_1"
echo "============================================================"

if [[ ! -f "$OVERRIDES_FILE" ]]; then
  echo "Error: $OVERRIDES_FILE not found. Run 3_generate_overrides.sh first."
  exit 1
fi

kubectl config use-context "$CONTEXT_1"

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

echo "=> Installing Apigee Datastore (Cassandra)..."
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

echo "=> Installing Apigee Environment ($ENV_NAME_1)..."
helm upgrade "$ENV_NAME_1" "$SCRIPT_DIR/$HELM_DIR/apigee-env" \
  --install \
  --namespace $NAMESPACE \
  --atomic \
  --set "env=$ENV_NAME_1" \
  -f "$OVERRIDES_FILE"

echo "=> Installing Apigee Virtualhost ($ENV_GROUP_NAME)..."
helm upgrade "apigee-virtualhost-${ENV_GROUP_NAME}" "$SCRIPT_DIR/$HELM_DIR/apigee-virtualhost" \
  --install \
  --namespace $NAMESPACE \
  --atomic \
  --set "envgroup=$ENV_GROUP_NAME" \
  -f "$OVERRIDES_FILE"

echo ""
echo "Done! Region 1 deployment complete."
echo "Check pods: kubectl get pods -n $NAMESPACE --context $CONTEXT_1"
