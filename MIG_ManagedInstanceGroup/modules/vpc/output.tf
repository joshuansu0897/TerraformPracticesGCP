output "vpc_main_id" {
  value       = google_compute_network.vpc_network.id
  description = "The ID of the VPC network"
}

output "frontend_subnet" {
  value       = google_compute_subnetwork.frontend_subnet.id
  description = "The ID of the frontend subnet"
}

output "backend_subnet" {
  value       = google_compute_subnetwork.backend_subnet.id
  description = "The ID of the backend subnet"
}
