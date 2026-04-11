#!/bin/bash
# 9_datastore_post_sync_upgrade.sh
# Removes multiRegionSeedHost and re-applies the datastore to finalize the cluster.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

OVERRIDES_FILE="$SCRIPT_DIR/overrides-dc-2.yaml"

echo "============================================================"
echo "Post-Sync: Removing Seed Host Lock on Region 2"
echo "============================================================"

kubectl config use-context "$CONTEXT_2"

echo "=> Removing multiRegionSeedHost from $OVERRIDES_FILE..."
if grep -q "multiRegionSeedHost" "$OVERRIDES_FILE"; then
    sed -i.bak '/multiRegionSeedHost/d' "$OVERRIDES_FILE"
    rm -f "${OVERRIDES_FILE}.bak"
    echo "   Removed successfully."
else
    echo "   Already removed."
fi

echo "=> Upgrading Apigee Datastore on Region 2 (without seedHost)..."
helm upgrade datastore "$SCRIPT_DIR/$HELM_DIR/apigee-datastore" \
  --install \
  --namespace $NAMESPACE \
  --atomic -f "$OVERRIDES_FILE"

echo ""
echo "Done! Multi-region Cassandra is fully independent."
echo "Proceed to 10_validate_replication.sh to verify."
