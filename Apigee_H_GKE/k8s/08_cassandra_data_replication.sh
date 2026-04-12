#!/bin/bash
# 8_cassandra_data_replication.sh
# Initiates cross-region data replication for Cassandra and waits for completion.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "============================================================"
echo "Initiating Cassandra Data Replication (dc-1 -> dc-2)"
echo "Context: $CONTEXT_2"
echo "============================================================"

kubectl config use-context "$CONTEXT_2"

# Get the apigeeorg CR name
ORG_REF=$(kubectl get apigeeorg -n $NAMESPACE -o jsonpath='{.items[0].metadata.name}')
if [[ -z "$ORG_REF" || "$ORG_REF" == "null" ]]; then
    echo "Error: Could not find apigeeorg resource. Is Region 2 fully deployed?"
    exit 1
fi
echo "=> ApigeeOrg Ref: $ORG_REF"

# Create and apply the CassandraDataReplication CR
cat <<EOF | kubectl apply -f -
apiVersion: apigee.cloud.google.com/v1alpha1
kind: CassandraDataReplication
metadata:
  name: region-expansion
  namespace: $NAMESPACE
spec:
  organizationRef: $ORG_REF
  force: false
  source:
    region: "dc-1"
EOF

echo "=> Waiting for data replication to complete..."
echo "   (This may take several minutes depending on data size)"
sleep 30

while true; do
  STATE=$(kubectl -n $NAMESPACE get apigeeds -o jsonpath='{.items[0].status.cassandraDataReplication.state}' 2>/dev/null || echo "pending")
  if [[ "$STATE" == "complete" ]]; then
      echo ""
      echo "Data replication COMPLETE!"
      break
  elif [[ "$STATE" == "failed" ]]; then
      echo ""
      echo "FAILED: Cassandra data replication failed. Check pod logs:"
      echo "  kubectl logs apigee-cassandra-default-0 -n $NAMESPACE --context $CONTEXT_2"
      exit 1
  else
      echo "  State: $STATE — waiting..."
      sleep 30
  fi
done

echo ""
echo "Done! Proceed to 9_datastore_post_sync_upgrade.sh"
