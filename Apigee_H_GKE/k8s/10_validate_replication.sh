#!/bin/bash
# 10_validate_replication.sh
# Validates multi-region Cassandra cluster health via nodetool status.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "============================================================"
echo "Validating Multi-Region Cassandra Cluster"
echo "============================================================"

echo ""
echo "========== Region 1 ($REGION_1) =========="
kubectl config use-context "$CONTEXT_1"

# Try to get JMX password from secret; fall back to asking
JMX_USER="jmxuser"
JMX_PASS=$(kubectl get secret apigee-datastore-default-creds -n $NAMESPACE \
  -o jsonpath='{.data.jmx\.password}' 2>/dev/null | base64 --decode 2>/dev/null || echo "")

if [[ -z "$JMX_PASS" ]]; then
  echo "Could not auto-detect JMX password. Trying without auth..."
  kubectl exec apigee-cassandra-default-0 -n $NAMESPACE -- nodetool status || true
else
  kubectl exec apigee-cassandra-default-0 -n $NAMESPACE -- nodetool -u "$JMX_USER" -pw "$JMX_PASS" status || true
fi

echo ""
echo "========== Region 2 ($REGION_2) =========="
kubectl config use-context "$CONTEXT_2"

JMX_PASS_2=$(kubectl get secret apigee-datastore-default-creds -n $NAMESPACE \
  -o jsonpath='{.data.jmx\.password}' 2>/dev/null | base64 --decode 2>/dev/null || echo "")

if [[ -z "$JMX_PASS_2" ]]; then
  echo "Could not auto-detect JMX password. Trying without auth..."
  kubectl exec apigee-cassandra-default-0 -n $NAMESPACE -- nodetool status || true
else
  kubectl exec apigee-cassandra-default-0 -n $NAMESPACE -- nodetool -u "$JMX_USER" -pw "$JMX_PASS_2" status || true
fi

echo ""
echo "============================================================"
echo "Validation complete!"
echo ""
echo "Expected output: Both dc-1 and dc-2 should appear with all"
echo "nodes showing status 'UN' (Up/Normal)."
echo "============================================================"
