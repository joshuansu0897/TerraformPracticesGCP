#!/bin/bash
# 4_pull_helm_charts.sh
# Pulls the Apigee Helm charts from Google Artifact Registry.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/config.sh"

echo "============================================================"
echo "Pulling Apigee Helm Charts v${CHART_VERSION}"
echo "============================================================"

HELM_ABS="$SCRIPT_DIR/$HELM_DIR"
mkdir -p "$HELM_ABS"

# Authenticate with Artifact Registry
echo "=> Authenticating helm with Artifact Registry..."
gcloud auth print-access-token | helm registry login -u oauth2accesstoken --password-stdin us-docker.pkg.dev

CHARTS=(
  apigee-operator
  apigee-datastore
  apigee-env
  apigee-ingress-manager
  apigee-org
  apigee-redis
  apigee-telemetry
  apigee-virtualhost
)

for chart in "${CHARTS[@]}"; do
  CHART_DIR="$HELM_ABS/$chart"

  if [[ -d "$CHART_DIR" ]] && [[ -f "$CHART_DIR/Chart.yaml" ]]; then
    echo "=> Skipping ${chart} (already pulled)"
    continue
  fi

  # Remove stale directory if it exists (no credentials here anymore)
  rm -rf "$CHART_DIR"

  echo "=> Pulling ${chart}..."
  helm pull "${CHART_REPO}/${chart}" --version "${CHART_VERSION}" --untar --untardir "$HELM_ABS"
done

echo ""
echo "Done! Charts extracted to $HELM_DIR"
ls -d "$HELM_ABS"/apigee-*/
