# Variables for the VPC module

variable "project_id" {
  type        = string
  description = "The ID of the project in which to create resources."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "The region in which to create resources."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC network."
}

variable "frontend_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "The CIDR block for the frontend subnet."
}

variable "backend_subnet_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "The CIDR block for the backend subnet."
}
