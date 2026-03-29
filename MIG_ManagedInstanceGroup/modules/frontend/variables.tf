variable "region" {
  type        = string
  description = "Region for frontend resources"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet for frontend instances"
}

variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "Machine type for frontend instances"
}


variable "min_replicas" {
  type        = number
  default     = 2
  description = "Minimum number of instances in frontend MIG"
}

variable "max_replicas" {
  type        = number
  default     = 5
  description = "Maximum number of instances in frontend MIG"
}
