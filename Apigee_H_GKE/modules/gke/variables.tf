variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "The region for the GKE cluster"
  type        = string
}

variable "network_id" {
  description = "The ID of the VPC network"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the hosted master network. This range will be used for assigning internal IP addresses to the master or set of masters, as well as the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network."
  type        = string
}

variable "node_locations" {
  description = "Specific zones to restrict the cluster and node pools to"
  type        = list(string)
  default     = []
}

variable "node_count_per_zone" {
  description = "Number of nodes per zone"
  type        = number
  default     = 1
}
