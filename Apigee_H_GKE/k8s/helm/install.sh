#!/bin/bash

# Set the chart repo and version
export CHART_REPO=oci://us-docker.pkg.dev/apigee-release/apigee-hybrid-helm-charts
export CHART_VERSION=1.14.0
export ENV_GROUP=prod-envgroup

####

# Pull all the helm charts
helm pull $CHART_REPO/apigee-operator --version $CHART_VERSION --untar
helm pull $CHART_REPO/apigee-datastore --version $CHART_VERSION --untar
helm pull $CHART_REPO/apigee-env --version $CHART_VERSION --untar
helm pull $CHART_REPO/apigee-ingress-manager --version $CHART_VERSION --untar
helm pull $CHART_REPO/apigee-org --version $CHART_VERSION --untar
helm pull $CHART_REPO/apigee-redis --version $CHART_VERSION --untar
helm pull $CHART_REPO/apigee-telemetry --version $CHART_VERSION --untar
helm pull $CHART_REPO/apigee-virtualhost --version $CHART_VERSION --untar

####

# Make the `create-service-account` tool executable:
chmod a+x ./apigee-operator/etc/tools/create-service-account

####

# To create each service account, run the tool and provide the Apigee hybrid runtime component profile, and directory location to store the certificate file of each service account:
./apigee-operator/etc/tools/create-service-account --profile apigee-cassandra --env prod --dir ./apigee-datastore
./apigee-operator/etc/tools/create-service-account --profile apigee-logger --env prod --dir ./apigee-telemetry
./apigee-operator/etc/tools/create-service-account --profile apigee-mart --env prod --dir ./apigee-org
./apigee-operator/etc/tools/create-service-account --profile apigee-metrics --env prod --dir ./apigee-telemetry

####

# Create service accounts from the remaining Apigee hybrid components:
./apigee-operator/etc/tools/create-service-account --profile apigee-runtime --env prod --dir ./apigee-env
./apigee-operator/etc/tools/create-service-account --profile apigee-synchronizer --env prod --dir ./apigee-env
./apigee-operator/etc/tools/create-service-account --profile apigee-udca --env prod --dir ./apigee-org
./apigee-operator/etc/tools/create-service-account --profile apigee-watcher --env prod --dir ./apigee-org

####

# Because the apigee-udca service account is needed for both organization-scope and environment-scope operations, copy the component's service account certificate file to the apigee-env chart directory:
cp ./apigee-org/${PROJECT_ID}-apigee-udca.json ./apigee-env

####

# Verify that the service account files were created in the correct directories by checking the contents of each chart's directory.
ls ./apigee-datastore ./apigee-telemetry ./apigee-org ./apigee-env

####

# Create a directory to store your TLS credential files:
mkdir ./apigee-virtualhost/certs

####

# Execute the command to create the TLS credentials (certificate and key files), and store them in your $APIGEE_HELM_CHARTS/apigee-virtualhost/certs directory:
openssl req -nodes -new -x509 -keyout ./apigee-virtualhost/certs/key-$ENV_GROUP.pem -out \
./apigee-virtualhost/certs/cert-$ENV_GROUP.pem -subj "/CN=${ORG}-${ENV}.hybrid-apigee.net"

####

# Inspect the details of the certificate:
sudo openssl x509 -in ./apigee-virtualhost/certs/cert-$ENV_GROUP.pem -text -noout | grep "CN"

####

# Verify that the certificate is valid:
sudo openssl x509 -in ./apigee-virtualhost/certs/cert-$ENV_GROUP.pem -text -noout | grep "Not"

