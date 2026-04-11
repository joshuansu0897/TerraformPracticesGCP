resource "google_dns_managed_zone" "public_zone" {
  name        = replace(var.domain_name, ".", "-")
  dns_name    = "${var.domain_name}." # Ensure it ends with a dot
  description = "Public DNS zone for ${var.domain_name}"
  project     = var.project_id

  visibility = "public"
}
