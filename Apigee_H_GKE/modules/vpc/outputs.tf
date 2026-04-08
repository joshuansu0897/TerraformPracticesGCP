output "network_id" {
  description = "The ID of the VPC."
  value       = google_compute_network.apigee_vpc.id
}

output "network_name" {
  description = "The name of the VPC."
  value       = google_compute_network.apigee_vpc.name
}

output "subnet_1_id" {
  description = "The ID of the first subnet."
  value       = google_compute_subnetwork.subnet_region_1.id
}

output "subnet_2_id" {
  description = "The ID of the second subnet."
  value       = google_compute_subnetwork.subnet_region_2.id
}
