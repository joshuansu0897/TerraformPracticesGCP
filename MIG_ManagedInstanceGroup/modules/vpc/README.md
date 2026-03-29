# VPC Module

This module is responsible for creating the foundation of our network infrastructure. It provisions a Virtual Private Cloud (VPC) network, subnets, NAT configuration, and necessary firewall rules to provide a secure and isolated environment for our application.

## Resources and Their Purpose

- **VPC Network (`google_compute_network.vpc_network`)**: Serves as the isolated network foundation where all our subsequent resources (subnets, load balancers, compute instances) will reside. It is configured without auto-created subnets so we have granular control over our CIDR ranges.
- **Frontend Subnet (`google_compute_subnetwork.frontend_subnet`)**: Dedicated subnet for the frontend Managed Instance Group (MIG). Providing a separate subnet allows us to strictly control network access and routing for frontend components.
- **Backend Subnet (`google_compute_subnetwork.backend_subnet`)**: Dedicated subnet for the backend MIG. This isolates backend services on a network level, ensuring they can only be reached through authorized paths (like from the frontend subnet).
- **Cloud Router (`google_compute_router.router`) & Cloud NAT (`google_compute_router_nat.nat`)**: Private instances without external IP addresses still need internet access to download packages or updates (e.g., during the execution of `startup.sh`). The Cloud Router and NAT gateway facilitate secure outbound connectivity without exposing the instances to inbound internet traffic.
- **Firewall Rule - Allow SSH IAP (`google_compute_firewall.allow_ssh_iap`)**: Allows secure SSH access to the instances without needing public IPs. Identity-Aware Proxy (IAP) tunnels SSH connections, requiring authentication and authorization, vastly improving security.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `project_id` | The ID of the GCP project where the VPC will be created. | `string` | required |
| `region` | The region in which to create resources. | `string` | `"us-central1"` |
| `vpc_cidr` | The CIDR block for the VPC network. | `string` | `"10.0.0.0/16"` |
| `frontend_subnet_cidr` | The CIDR block for the frontend subnet. | `string` | `"10.0.1.0/24"` |
| `backend_subnet_cidr` | The CIDR block for the backend subnet. | `string` | `"10.0.2.0/24"` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_main_id` | The ID of the VPC network |
| `frontend_subnet` | The ID of the frontend subnet |
| `backend_subnet` | The ID of the backend subnet |
