# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL LOAD BALANCER (FRONTEND)
# ---------------------------------------------------------------------------------------------------------------------

# Reserve a global static IP for the Frontend Load Balancer
resource "google_compute_global_address" "default" {
  name = "frontend-lb-ip"
}

# Health Check for Frontend
resource "google_compute_health_check" "frontend_hc" {
  name               = "frontend-hc"
  check_interval_sec = 10
  timeout_sec        = 5
  tcp_health_check {
    port = 80
  }
}

# Backend Service for Frontend LB
resource "google_compute_backend_service" "frontend_backend_service" {
  name                  = "frontend-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.frontend_hc.id]

  backend {
    group           = var.frontend_mig_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# URL Map for Frontend
resource "google_compute_url_map" "frontend_url_map" {
  name            = "frontend-url-map"
  default_service = google_compute_backend_service.frontend_backend_service.id
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "frontend_http_proxy" {
  name    = "frontend-http-proxy"
  url_map = google_compute_url_map.frontend_url_map.id
}

# Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "frontend_forwarding_rule" {
  name                  = "frontend-forwarding-rule"
  target                = google_compute_target_http_proxy.frontend_http_proxy.id
  port_range            = "80"
  ip_address            = google_compute_global_address.default.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# ---------------------------------------------------------------------------------------------------------------------
# INTERNAL LOAD BALANCER (BACKEND)
# ---------------------------------------------------------------------------------------------------------------------

# Health Check for Backend
resource "google_compute_region_health_check" "backend_hc" {
  name               = "backend-hc"
  region             = var.region
  check_interval_sec = 10
  timeout_sec        = 5
  tcp_health_check {
    port = 80
  }
}

# Backend Service for Internal LB
resource "google_compute_region_backend_service" "backend_service" {
  name                  = "backend-internal-service"
  region                = var.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.backend_hc.id]

  backend {
    group          = var.backend_mig_group
    balancing_mode = "CONNECTION"
  }
}

# Internal Forwarding Rule
resource "google_compute_forwarding_rule" "backend_forwarding_rule" {
  name                  = "backend-forwarding-rule"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  ports                 = ["80"]
  network               = var.vpc_id
  subnetwork            = var.backend_subnet_id
  backend_service       = google_compute_region_backend_service.backend_service.id
}
