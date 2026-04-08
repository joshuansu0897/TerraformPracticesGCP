variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region_1" {
  description = "The first region for the Apigee cluster"
  type        = string
  default     = "us-west1"
}

variable "region_2" {
  description = "The second region for the Apigee cluster"
  type        = string
  default     = "us-east1"
}

variable "gke_master_ipv4_cidr_1" {
  description = "The CIDR range for Region 1 GKE Master"
  type        = string
  default     = "172.16.0.0/28"
}

variable "gke_master_ipv4_cidr_2" {
  description = "The CIDR range for Region 2 GKE Master"
  type        = string
  default     = "172.16.0.16/28"
}
