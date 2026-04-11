output "name_servers" {
  description = "The nameservers associated with the Cloud DNS zone"
  value       = google_dns_managed_zone.public_zone.name_servers
}
