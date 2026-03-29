# Load Balancer Module

This module is responsible for distributing traffic across our application. It sets up an External Global HTTP Load Balancer to route internet traffic to the frontend MIG, and an Internal TCP Load Balancer to route requests from the frontend to the backend MIG.

## Resources and Their Purpose

**Global Frontend Load Balancer Components:**
- **Global IP Address (`google_compute_global_address.default`)**: Reserves a static, globally reachable IP address that users will hit to access the frontend application.
- **Health Check (`google_compute_health_check.frontend_hc`)**: Periodically probes the frontend instances to ensure they are available before the load balancer routes traffic to them.
- **Backend Service (`google_compute_backend_service.frontend_backend_service`)**: Groups the frontend MIG and applies our traffic distribution strategy (Utilization balancing mode). It acts as the brain behind where traffic is directed.
- **URL Map (`google_compute_url_map.frontend_url_map`)**: Defines how HTTP/HTTPS requests should be routed to backend services. Useful for path-based routing, although here it utilizes a default service rule.
- **Target HTTP Proxy (`google_compute_target_http_proxy.frontend_http_proxy`)**: Receives the user request from the forwarding rule and evaluates it against the URL Map to determine where to send it.
- **Global Forwarding Rule (`google_compute_global_forwarding_rule.frontend_forwarding_rule`)**: Listens on the global IP address on specific ports (like 80) and sends the incoming traffic to the Target HTTP Proxy.

**Internal Backend Load Balancer Components:**
- **Regional Health Check (`google_compute_region_health_check.backend_hc`)**: Ensures that backend instances are capable of handling traffic. It's regional since internal load balancing is constrained to a single region.
- **Regional Backend Service (`google_compute_region_backend_service.backend_service`)**: Configures how the internal connections are load balanced (TCP connection balancing mode) among the backend instances.
- **Forwarding Rule (`google_compute_forwarding_rule.backend_forwarding_rule`)**: Acts as the front door for the backend tier inside the VPC network. It listens for traffic from the frontend subnet and sends it securely to the region backend service.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `region` | Region for load balancer components. | `string` | required |
| `vpc_id` | The ID of the VPC network. | `string` | required |
| `backend_subnet_id` | The ID of the backend subnet for the internal load balancer. | `string` | required |
| `frontend_mig_group` | The instance group link for the frontend MIG. | `string` | required |
| `backend_mig_group` | The instance group link for the backend MIG. | `string` | required |

## Outputs

| Name | Description |
|------|-------------|
| `frontend_lb_ip` | The IP address of the Global External HTTP Load Balancer for the frontend. |
| `backend_ilb_ip` | The internal IP address of the Internal Load Balancer for the backend. |
