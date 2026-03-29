# Backend Instance Template
resource "google_compute_instance_template" "backend_template" {
  name_prefix  = "backend-template-"
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
  }

  metadata_startup_script = file("${path.module}/startup.sh")

  tags = ["backend-mig", "allow-health-check-backend"]

  lifecycle {
    create_before_destroy = true
  }
}

# Backend Regional Managed Instance Group
resource "google_compute_region_instance_group_manager" "backend_mig" {
  name               = "backend-mig"
  region             = var.region
  base_instance_name = "backend-inst"

  version {
    instance_template = google_compute_instance_template.backend_template.id
    name              = "primary"
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_region_health_check.autohealing.id
    initial_delay_sec = 300
  }
}

# Autohealing Health Check
resource "google_compute_region_health_check" "autohealing" {
  name                = "backend-autohealing-hc"
  region              = var.region
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# Backend Autoscaler
resource "google_compute_region_autoscaler" "backend_autoscaler" {
  name   = "backend-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.backend_mig.id

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
resource "google_compute_firewall" "allow_health_checks_backend" {
  name    = "allow-health-checks-backend"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # Health check IP ranges
  target_tags   = ["allow-health-check-backend"]
}

# Firewall rule to allow traffic from Frontend Subnet
resource "google_compute_firewall" "allow_frontend_to_backend" {
  name    = "allow-frontend-to-backend"
  network = var.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_tags = var.frontend_tags
  target_tags = ["backend-mig"]
}
