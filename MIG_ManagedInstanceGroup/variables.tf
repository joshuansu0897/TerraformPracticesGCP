# Variables for the Managed Instance Group module
variable "project_id" {
  type        = string
  description = "The ID of the project in which to create resources."
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "The region in which to create resources."
}
