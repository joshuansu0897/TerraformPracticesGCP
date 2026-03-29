# Frontend Instance Template
resource "google_compute_instance_template" "frontend_template" {
  name_prefix  = "frontend-template-"
  machine_type = var.machine_type
  region       = var.region

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.subnet_id
    # Ensure frontend instances don't get public IPs (we use Global LB instead)
  }

  metadata_startup_script = file("${path.module}/startup.sh")

  tags = ["frontend-mig", "allow-health-check"]

  lifecycle {
    create_before_destroy = true
  }
}

# Frontend Regional Managed Instance Group
resource "google_compute_region_instance_group_manager" "frontend_mig" {
  name               = "frontend-mig"
  region             = var.region
  base_instance_name = "frontend-inst"

  version {
    instance_template = google_compute_instance_template.frontend_template.id
    name              = "primary"
  }

  named_port {
    name = "http"
    port = 80
  }
}

# Frontend Autoscaler
resource "google_compute_region_autoscaler" "frontend_autoscaler" {
  name   = "frontend-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.frontend_mig.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

# Firewall rule to allow health checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-health-checks-frontend"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # Health check IP ranges
  target_tags   = ["allow-health-check"]
}
