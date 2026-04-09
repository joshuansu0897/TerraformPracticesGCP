output "vpc_network_id" {
  description = "The ID of the VPC."
  value       = module.vpc.network_id
}

output "vpc_network_name" {
  description = "The name of the VPC configuration."
  value       = module.vpc.network_name
}

output "subnet_1_id" {
  description = "The ID of the subnet in region 1."
  value       = module.vpc.subnet_1_id
}

output "subnet_2_id" {
  description = "The ID of the subnet in region 2."
  value       = module.vpc.subnet_2_id
}

output "cluster_1_name" {
  description = "Name of the GKE cluster in Region 1"
  value       = module.gke_region_1.cluster_name
}

output "cluster_2_name" {
  description = "Name of the GKE cluster in Region 2"
  value       = module.gke_region_2.cluster_name
}

output "apigee_service_accounts" {
  description = "The emails of the Apigee service accounts created"
  value       = module.iam.service_accounts
}

output "apigee_org_id" {
  description = "The ID of the Apigee organization"
  value       = module.apigee.org_id
}

output "apigee_env_group" {
  description = "The ID of the Apigee Environment Group"
  value       = module.apigee.envgroup_id
}

output "apigee_env_region_1" {
  description = "Name of the Region 1 Apigee environment"
  value       = module.apigee.env_region_1_name
}

output "apigee_env_region_2" {
  description = "Name of the Region 2 Apigee environment"
  value       = module.apigee.env_region_2_name
}
