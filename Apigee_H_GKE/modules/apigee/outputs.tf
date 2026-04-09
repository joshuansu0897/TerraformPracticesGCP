output "org_id" {
  description = "The ID of the Apigee organization"
  value       = google_apigee_organization.apigee_org.id
}

output "envgroup_id" {
  description = "The ID of the Apigee Env Group"
  value       = google_apigee_envgroup.env_group.id
}

output "env_region_1_name" {
  description = "Name of the Region 1 environment"
  value       = google_apigee_environment.env_region_1.name
}

output "env_region_2_name" {
  description = "Name of the Region 2 environment"
  value       = google_apigee_environment.env_region_2.name
}
