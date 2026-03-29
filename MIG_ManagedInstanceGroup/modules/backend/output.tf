output "instance_group" {
  value       = google_compute_region_instance_group_manager.backend_mig.instance_group
  description = "The instance group of the backend MIG."
}
