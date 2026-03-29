output "instance_group" {
  value       = google_compute_region_instance_group_manager.frontend_mig.instance_group
  description = "The instance group of the frontend MIG."
}

output "tags" {
  value       = google_compute_instance_template.frontend_template.tags
  description = "The tags of the frontend MIG."
}
