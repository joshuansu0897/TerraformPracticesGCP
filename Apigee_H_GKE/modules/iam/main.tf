locals {
  service_accounts = {
    "apigee-logger"       = { role = "roles/logging.logWriter",  ksa = "apigee-logger",      dir = "apigee-telemetry" }
    "apigee-metrics"      = { role = "roles/monitoring.metricWriter", ksa = "apigee-metrics", dir = "apigee-telemetry" }
    "apigee-cassandra"    = { role = "roles/storage.objectAdmin", ksa = "apigee-cassandra",  dir = "apigee-datastore" }
    "apigee-mart"         = { role = "roles/apigeeconnect.Agent", ksa = "apigee-mart",       dir = "apigee-org" }
    "apigee-udca"         = { role = "roles/apigee.analyticsAgent", ksa = "apigee-udca",     dir = "apigee-org" }
    "apigee-synchronizer" = { role = "roles/apigee.synchronizerManager", ksa = "apigee-synchronizer", dir = "apigee-env" }
    "apigee-watcher"      = { role = "roles/apigee.runtimeAgent", ksa = "apigee-watcher",    dir = "apigee-org" }
    "apigee-runtime"      = { role = null,                         ksa = "apigee-runtime",    dir = "apigee-env" }
  }

  sa_roles = {
    for k, v in local.service_accounts : k => v if v.role != null
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
  for_each = local.sa_roles
  project  = var.project_id
  role     = each.value.role
  member   = "serviceAccount:${google_service_account.apigee_sa[each.key].email}"
}

# Bind GSA to KSA via Workload Identity
resource "google_service_account_iam_member" "workload_identity_binding" {
  for_each           = local.service_accounts
  service_account_id = google_service_account.apigee_sa[each.key].name
  role               = "roles/iam.workloadIdentityUser"

  # The Workload Identity member pattern:
  member = "serviceAccount:${var.project_id}.svc.id.goog[${var.namespace}/${each.value.ksa}]"
}

# Create JSON Keys
resource "google_service_account_key" "keys" {
  for_each           = local.service_accounts
  service_account_id = google_service_account.apigee_sa[each.key].name
}

# Dump JSON Keys to k8s/credentials directory (separate from helm charts)
resource "local_file" "sa_keys" {
  for_each = local.service_accounts
  content  = base64decode(google_service_account_key.keys[each.key].private_key)
  filename = "${path.module}/../../k8s/credentials/${var.project_id}-${each.key}.json"
}
