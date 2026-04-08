# Configure the Google Cloud provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0" # Make sure version is recent enough for all features
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
  cluster_name           = "apigee-cluster-west"
  region                 = var.region_1
  network_id             = module.vpc.network_id
  subnet_id              = module.vpc.subnet_1_id
  master_ipv4_cidr_block = var.gke_master_ipv4_cidr_1

  depends_on = [module.vpc]
}

# Module for region 2 GKE cluster
module "gke_region_2" {
  source                 = "./modules/gke"
  project_id             = var.project_id
  cluster_name           = "apigee-cluster-east"
  region                 = var.region_2
  network_id             = module.vpc.network_id
  subnet_id              = module.vpc.subnet_2_id
  master_ipv4_cidr_block = var.gke_master_ipv4_cidr_2

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
