locals {
  service_accounts = {
    "apigee-logger"       = { role = "roles/logging.logWriter", ksa = "apigee-logger" }
    "apigee-metrics"      = { role = "roles/monitoring.metricWriter", ksa = "apigee-metrics" }
    "apigee-cassandra"    = { role = "roles/storage.objectAdmin", ksa = "apigee-cassandra" }
    "apigee-mart"         = { role = "roles/apigeeconnect.Agent", ksa = "apigee-mart" }
    "apigee-udca"         = { role = "roles/apigee.analyticsAgent", ksa = "apigee-udca" }
    "apigee-synchronizer" = { role = "roles/apigee.synchronizerManager", ksa = "apigee-synchronizer" }
  }
}

# Create Google Service Accounts
resource "google_service_account" "apigee_sa" {
  for_each     = local.service_accounts
  account_id   = each.key
  display_name = "Apigee Hybrid ${each.key} Service Account"
  project      = var.project_id
}

# Assign Project IAM Roles
resource "google_project_iam_member" "apigee_sa_role" {
  for_each = local.service_accounts
  project  = var.project_id
  role     = each.value.role
  member   = "serviceAccount:${google_service_account.apigee_sa[each.key].email}"
}

# Bind GSA to KSA via Workload Identity
# This creates the IAM binding allowing the Kubernetes service account to impersonate the GSA
resource "google_service_account_iam_member" "workload_identity_binding" {
  for_each           = local.service_accounts
  service_account_id = google_service_account.apigee_sa[each.key].name
  role               = "roles/iam.workloadIdentityUser"

  # The Workload Identity member pattern:
  # serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]
  member = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${each.value.ksa}]"
}
