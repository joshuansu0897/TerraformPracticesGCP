variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Apigee hybrid components"
  type        = string
  default     = "apigee"
}
