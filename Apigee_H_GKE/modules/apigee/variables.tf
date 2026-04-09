variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "analytics_region" {
  description = "Primary region for Apigee analytics"
  type        = string
}

variable "env_group_name" {
  description = "Name for the Apigee environment group"
  type        = string
  default     = "prod-envgroup"
}

variable "env_group_hostnames" {
  description = "Hostnames mapped to the environment group"
  type        = list(string)
  default     = ["api.example.com"]
}

variable "region_1" {
  description = "Region 1 name"
  type        = string
}

variable "region_2" {
  description = "Region 2 name"
  type        = string
}
