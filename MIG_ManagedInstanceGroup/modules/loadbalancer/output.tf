output "frontend_lb_ip" {
  value       = google_compute_global_address.default.address
  description = "The IP address of the Global External HTTP Load Balancer for the frontend."
}

output "backend_ilb_ip" {
  value       = google_compute_forwarding_rule.backend_forwarding_rule.ip_address
  description = "The internal IP address of the Internal Load Balancer for the backend."
}
