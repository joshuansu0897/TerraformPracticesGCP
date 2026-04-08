# Create the Custom VPC
resource "google_compute_network" "apigee_vpc" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# Subnet in Region 1
resource "google_compute_subnetwork" "subnet_region_1" {
  name          = "${var.network_name}-subnet-${var.region_1}"
  project       = var.project_id
  region        = var.region_1
  network       = google_compute_network.apigee_vpc.self_link
  ip_cidr_range = var.subnet_1_cidr
}

# Subnet in Region 2
resource "google_compute_subnetwork" "subnet_region_2" {
  name          = "${var.network_name}-subnet-${var.region_2}"
  project       = var.project_id
  region        = var.region_2
  network       = google_compute_network.apigee_vpc.self_link
  ip_cidr_range = var.subnet_2_cidr
}

# Firewall rule for Cassandra cross-region communication (ports 7000, 7001, 9042)
resource "google_compute_firewall" "allow_cassandra_inter_region" {
  name    = "${var.network_name}-allow-cassandra"
  project = var.project_id
  network = google_compute_network.apigee_vpc.name
  
  description = "Allow inter-region Cassandra communication for Apigee hybrid nodes"

  allow {
    protocol = "tcp"
    ports    = ["7000", "7001", "9042"]
  }

  # Allow traffic originating from either subnet
  source_ranges = [
    var.subnet_1_cidr,
    var.subnet_2_cidr
  ]
}
