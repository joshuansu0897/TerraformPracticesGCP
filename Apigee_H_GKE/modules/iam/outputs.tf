output "service_accounts" {
  description = "A map of the created Apigee hybrid service account emails"
  value       = { for k, v in google_service_account.apigee_sa : k => v.email }
}
