output "instance_group" {
  value       = google_compute_region_instance_group_manager.frontend_mig.instance_group
  description = "The instance group of the frontend MIG."
}
