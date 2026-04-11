terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  # Region on the provider level is optional but often set to the primary region.
  region = var.region_1
}

############
## API Enablement
############

# Enable Compute Engine API
resource "google_project_service" "compute_api" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# Enable GKE API
resource "google_project_service" "gke_api" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

# Enable Apigee API
resource "google_project_service" "apigee_api" {
  project            = var.project_id
  service            = "apigee.googleapis.com"
  disable_on_destroy = false
}

# Enable Apigee Connect API
resource "google_project_service" "apigee_connect_api" {
  project            = var.project_id
  service            = "apigeeconnect.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud Pub/Sub API
resource "google_project_service" "pubsub_api" {
  project            = var.project_id
  service            = "pubsub.googleapis.com"
  disable_on_destroy = false
}

############
## Modules
############

# Module for creating the VPC network, Subnets, and Firewall Rules
module "vpc" {
  source     = "./modules/vpc"
  project_id = var.project_id
  region_1   = var.region_1
  region_2   = var.region_2

  depends_on = [google_project_service.compute_api, google_project_service.gke_api]
}

# Module for region 1 GKE cluster
module "gke_region_1" {
  source                 = "./modules/gke"
  project_id             = var.project_id
  cluster_name           = "apigee-cluster-${var.region_1}"
  region                 = var.region_1
  network_id             = module.vpc.network_id
  subnet_id              = module.vpc.subnet_1_id
  master_ipv4_cidr_block = var.gke_master_ipv4_cidr_1

  node_locations      = ["${var.region_1}-a", "${var.region_1}-b"]
  node_count_per_zone = 1

  depends_on = [module.vpc]
}

# Module for region 2 GKE cluster
module "gke_region_2" {
  source                 = "./modules/gke"
  project_id             = var.project_id
  cluster_name           = "apigee-cluster-${var.region_2}"
  region                 = var.region_2
  network_id             = module.vpc.network_id
  subnet_id              = module.vpc.subnet_2_id
  master_ipv4_cidr_block = var.gke_master_ipv4_cidr_2

  node_locations      = ["${var.region_2}-a", "${var.region_2}-b"]
  node_count_per_zone = 1

  depends_on = [module.vpc]
}

# Module for Service Accounts and IAM Bindings (Workload Identity)
module "iam" {
  source     = "./modules/iam"
  project_id = var.project_id
  namespace  = "apigee" # Default Apigee namespace

  # Wait for at least one GKE cluster to create the Workload Identity Pool
  depends_on = [module.gke_region_1, module.gke_region_2]
}

# Module for Apigee Control Plane Config
module "apigee" {
  source              = "./modules/apigee"
  project_id          = var.project_id
  analytics_region    = var.region_1
  region_1            = var.region_1
  region_2            = var.region_2
  env_group_hostnames = ["${var.domain_name}"]

  depends_on = [google_project_service.apigee_api]
}

# Module for Cloud DNS Public Zone
module "dns" {
  source      = "./modules/dns"
  project_id  = var.project_id
  domain_name = var.domain_name
}

# --------- Automated TLS Cert Generation for Apigee Virtualhost ---------
resource "tls_private_key" "apigee_vh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "apigee_vh" {
  private_key_pem = tls_private_key.apigee_vh.private_key_pem

  subject {
    common_name = var.domain_name
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "local_file" "vh_cert" {
  content  = tls_self_signed_cert.apigee_vh.cert_pem
  filename = "${path.module}/k8s/credentials/cert-prod-envgroup.pem"
}

resource "local_file" "vh_key" {
  content  = tls_private_key.apigee_vh.private_key_pem
  filename = "${path.module}/k8s/credentials/key-prod-envgroup.pem"
}
