# Apigee Hybrid on GKE - Multi-Region Deployment Automation

This directory contains a sequence of shell scripts designed to fully automate the Kubernetes deployment portion of Apigee Hybrid on GKE in a **Multi-Region Topology** (`Active-Active` or `Active-Passive`). 

The infrastructure footprint (VPC, Regional Clusters, Node Pools, Service Accounts, and TLS Certificates) is already configured by Terraform. 

These scripts correspond to the [Official Multi-Region Guide](https://cloud.google.com/apigee/docs/hybrid/v1.16/multi-region).

## Execution Order

You must execute these scripts **in numerical order**. Ensure you are authenticated with GCP via `gcloud auth login` before starting.

| Order | Script | Description |
| :--- | :--- | :--- |
| **1.** | `01_configure_gke_credentials.sh` | Fetches standard credentials for your `us-west1` and `us-central1` GKE clusters for `kubectl` locally. |
| **2.** | `02_storageclass.sh` | Installs SSD StorageClasses and `cert-manager` on both `us-west1` and `us-central1` clusters. |
| **3.** | `03_generate_overrides.sh` | Dynamically generates `overrides-dc-1.yaml` (Region 1) and `overrides-dc-2.yaml` (Region 2) based on your Terraform configuration and injected keys. |
| **4.** | `04_pull_helm_charts.sh` | Downloads the `apigee-*` Helm charts into the `./helm` folder required for installation. |
| **5.** | `05_deploy_region_1.sh` | Completely installs Apigee Hybrid (Operator, Datastore, Telemetry, Redis, Ingress, Org, Env) onto the **Region 1** (`us-west1`) cluster via Helm. |
| **6.** | `06_multi_region_sync.sh` | Copies the `apigee-ca` mTLS certificates from Region 1 and propagates them to **Region 2** (`us-central1`). Extracts your Region 1 Cassandra Seed IP and updates `overrides-dc-2.yaml`. |
| **7.** | `07_deploy_region_2_datastore.sh` | Installs the Apigee Operator and Datastore (Cassandra) onto the **Region 2** (`us-central1`) cluster. |
| **8.** | `08_cassandra_data_replication.sh` | Initiates the Cross-Region Data Replication using the `CassandraDataReplication` Custom Resource. Will wait until replication state changes to `complete`. |
| **9.** | `09_validate_replication.sh` | An interactive test script to validate `nodetool status` between Cassandra pods across regions to ensure native IP gossip routing is functioning perfectly over your VPC. |
| **10.** | `10_deploy_region_2_components.sh` | Once replication finishes, this removes the Seed Host lock from `overrides-dc-2.yaml` and completes the `telemetry`, `redis`, `ingress`, `org`, and `env` Helm deployments on **Region 2**. |

## Important Notes
- Always run these from within the `k8s/` directory to ensure relative paths stay correct (e.g., `cd k8s && ./01_configure_gke_credentials.sh`).
- If replication verification in step 8 fails or hangs, check pod logs. Do not run step 10 unless Step 8 completes successfully!
