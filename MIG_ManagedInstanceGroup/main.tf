# Configure the Google Cloud provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.25.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

############
## API Enablement
############

# Enable Compute Engine API
resource "google_project_service" "compute_api" {
  project            = var.project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = true
}

############
## Modules
############

# Module for creating the VPC network and Subnets
module "vpc" {
  source     = "./modules/vpc"
  project_id = var.project_id
  region     = var.region

  depends_on = [google_project_service.compute_api]
}

# Module for Frontend MIG
module "frontend" {
  source    = "./modules/frontend"
  region    = var.region
  vpc_id    = module.vpc.vpc_main_id
  subnet_id = module.vpc.frontend_subnet

  depends_on = [module.vpc]
}

# Module for Backend MIG
module "backend" {
  source        = "./modules/backend"
  region        = var.region
  vpc_id        = module.vpc.vpc_main_id
  subnet_id     = module.vpc.backend_subnet
  frontend_tags = module.frontend.tags

  depends_on = [module.vpc, module.frontend]
}

# Module for Load Balancing
module "loadbalancer" {
  source             = "./modules/loadbalancer"
  region             = var.region
  vpc_id             = module.vpc.vpc_main_id
  backend_subnet_id  = module.vpc.backend_subnet
  frontend_mig_group = module.frontend.instance_group
  backend_mig_group  = module.backend.instance_group

  depends_on = [module.vpc, module.frontend, module.backend]
}
