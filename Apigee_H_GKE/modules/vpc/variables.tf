variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "network_name" {
  description = "The name of the VPC network"
  type        = string
  default     = "apigee-vpc"
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

variable "subnet_1_cidr" {
  description = "CIDR range for subnet in region 1"
  type        = string
  default     = "10.10.0.0/20"
}

variable "subnet_2_cidr" {
  description = "CIDR range for subnet in region 2"
  type        = string
  default     = "10.20.0.0/20"
}
