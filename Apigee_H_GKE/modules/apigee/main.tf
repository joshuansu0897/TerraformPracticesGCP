# Apigee Organization configured for HYBRID
resource "google_apigee_organization" "apigee_org" {
  project_id       = var.project_id
  analytics_region = var.analytics_region
  runtime_type     = "HYBRID"
}

# Regional Environments
resource "google_apigee_environment" "env_region_1" {
  org_id       = google_apigee_organization.apigee_org.id
  name         = "prod-${var.region_1}"
  description  = "Apigee Environment for ${var.region_1} Region"
  display_name = "Prod ${var.region_1}"
}

resource "google_apigee_environment" "env_region_2" {
  org_id       = google_apigee_organization.apigee_org.id
  name         = "prod-${var.region_2}"
  description  = "Apigee Environment for ${var.region_2} Region"
  display_name = "Prod ${var.region_2}"
}

# Environment Group
resource "google_apigee_envgroup" "env_group" {
  org_id    = google_apigee_organization.apigee_org.id
  name      = var.env_group_name
  hostnames = var.env_group_hostnames
}

# Attach Environments to the Group
resource "google_apigee_envgroup_attachment" "env_region_1_attachment" {
  envgroup_id = google_apigee_envgroup.env_group.id
  environment = google_apigee_environment.env_region_1.name
}

resource "google_apigee_envgroup_attachment" "env_region_2_attachment" {
  envgroup_id = google_apigee_envgroup.env_group.id
  environment = google_apigee_environment.env_region_2.name
}
