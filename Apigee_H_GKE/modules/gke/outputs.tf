output "cluster_name" {
  description = "The name of the cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The IP address of the cluster master."
  value       = google_container_cluster.primary.endpoint
}

output "ca_certificate" {
  description = "The cluster ca certificate"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}
