variable "region" {
  type        = string
  description = "Region for load balancer components"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC network"
}

variable "backend_subnet_id" {
  type        = string
  description = "The ID of the backend subnet for the internal load balancer"
}

variable "frontend_mig_group" {
  type        = string
  description = "The instance group link for the frontend MIG"
}

variable "backend_mig_group" {
  type        = string
  description = "The instance group link for the backend MIG"
}
