variable "region" {
  type        = string
  description = "Region for backend resources"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet for backend instances"
}

variable "frontend_subnet_cidr" {
  type        = string
  description = "The CIDR block of the frontend subnet to allow access"
}

variable "machine_type" {
  type        = string
  default     = "e2-micro"
  description = "Machine type for backend instances"
}

variable "min_replicas" {
  type        = number
  default     = 2
  description = "Minimum number of instances in backend MIG"
}

variable "max_replicas" {
  type        = number
  default     = 5
  description = "Maximum number of instances in backend MIG"
}
