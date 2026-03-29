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

variable "frontend_tags" {
  type        = list(string)
  description = "The tags of the frontend MIG."
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
