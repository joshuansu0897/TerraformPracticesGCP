#!/bin/bash
# 6_multi_region_sync.sh
# Copies CA certificates from Region 1 to Region 2 and discovers Cassandra Seed IP.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "============================================================"
echo "Synchronizing Region 1 -> Region 2"
echo "============================================================"

# --- Step 1: Extract secrets from Region 1 ---
echo "=> Switching to Region 1 context ($CONTEXT_1)..."
kubectl config use-context "$CONTEXT_1"

echo "=> Exporting namespace configuration..."
kubectl get namespace $NAMESPACE -o yaml > "$SCRIPT_DIR/apigee-namespace.yaml"

echo "=> Exporting apigee-ca secret from cert-manager..."
kubectl -n cert-manager get secret apigee-ca -o yaml > "$SCRIPT_DIR/apigee-ca.yaml"

# --- Step 2: Extract Cassandra Seed IP ---
echo "=> Waiting for Cassandra pod in Region 1..."
kubectl wait --for=condition=ready pod/apigee-cassandra-default-0 -n $NAMESPACE --timeout=600s

SEED_IP=$(kubectl get pod apigee-cassandra-default-0 -n $NAMESPACE -o jsonpath='{.status.podIP}')
if [[ -z "$SEED_IP" || "$SEED_IP" == "<none>" ]]; then
   echo "Error: Could not extract Cassandra Seed IP from Region 1."
   kubectl get pods -o wide -n $NAMESPACE
   exit 1
fi
echo "=> Cassandra Seed IP: $SEED_IP"

# --- Step 3: Apply secrets to Region 2 ---
echo "=> Switching to Region 2 context ($CONTEXT_2)..."
kubectl config use-context "$CONTEXT_2"

echo "=> Creating namespace in Region 2..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "=> Importing apigee-ca secret to Region 2 cert-manager..."
# Strip cluster-specific metadata before applying
kubectl -n cert-manager apply -f <(cat "$SCRIPT_DIR/apigee-ca.yaml" | \
  grep -v "resourceVersion:" | \
  grep -v "uid:" | \
  grep -v "creationTimestamp:" | \
  grep -v "selfLink:")

# Clean up temporary files
rm -f "$SCRIPT_DIR/apigee-namespace.yaml" "$SCRIPT_DIR/apigee-ca.yaml"

# --- Step 4: Inject multiRegionSeedHost into overrides-dc-2.yaml ---
echo "=> Updating overrides-dc-2.yaml with multiRegionSeedHost: $SEED_IP"
OVERRIDES_DC2="$SCRIPT_DIR/overrides-dc-2.yaml"

if grep -q "multiRegionSeedHost" "$OVERRIDES_DC2"; then
    # Replace existing value
    sed -i.bak "s/multiRegionSeedHost:.*/multiRegionSeedHost: \"$SEED_IP\"/" "$OVERRIDES_DC2"
    rm -f "${OVERRIDES_DC2}.bak"
else
    # Insert after the cassandra: line
    sed -i.bak "/^cassandra:/a\\
\\  multiRegionSeedHost: \"$SEED_IP\"
" "$OVERRIDES_DC2"
    rm -f "${OVERRIDES_DC2}.bak"
fi

echo ""
echo "Done! Region 2 is ready for deployment."
echo "Proceed to script 7_deploy_region_2_components.sh"
