output "frontend_global_ip" {
  value       = module.loadbalancer.frontend_lb_ip
  description = "The Global IP for the Frontend Load Balancer. Visit this IP in your browser to test the deployment."
}

output "backend_internal_ip" {
  value       = module.loadbalancer.backend_ilb_ip
  description = "The Internal IP for the Backend Load Balancer. Accessible only from the VPC."
}
