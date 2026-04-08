resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  network  = var.network_id
  subnetwork = var.subnet_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Ensure VPC-native cluster (alias IPs enabled), standard for modern GKE and required by Apigee
  ip_allocation_policy {
    # Leaving empty utilizes auto-allocated secondary ranges if not explicitly provided
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "apigee_nodes" {
  name       = "apigee-pool"
  cluster    = google_container_cluster.primary.name
  location   = var.region
  
  # Minimum of 3 nodes as requested
  node_count = 3

  node_config {
    machine_type = "e2-standard-4"
    
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    # Use Workload Identity for nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      role = "apigee-runtime"
    }
  }
}

# Install cert-manager via local-exec
resource "null_resource" "install_cert_manager" {
  depends_on = [google_container_node_pool.apigee_nodes]

  triggers = {
    cluster_name = google_container_cluster.primary.name
  }

  provisioner "local-exec" {
    command = <<EOT
      gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region} --project ${var.project_id}
      helm repo add jetstack https://charts.jetstack.io
      helm repo update
      helm upgrade --install cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --version v1.12.0 \
        --set installCRDs=true
    EOT
  }
}
