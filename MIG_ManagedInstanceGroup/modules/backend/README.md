# Backend Module

This module provisions the backend tier of our application. Similar to the frontend, it relies on Managed Instance Groups and autoscaling, but with tighter network security policies to ensure business logic remains isolated from the public internet.

## Resources and Their Purpose

- **Instance Template (`google_compute_instance_template.backend_template`)**: Provides the configuration blueprint for our backend services. It specifies the base image, hardware flavor, and execution of a startup script designed specifically to initialize the backend application.
- **Regional Managed Instance Group (`google_compute_region_instance_group_manager.backend_mig`)**: Manages deployment and redundancy of backend instances across different zones within the region. It self-heals instances using an auto-healing policy, thereby offering a reliable environment for critical logic.
- **Autohealing Health Check (`google_compute_region_health_check.autohealing`)**: A regional HTTP health check used exclusively by the backend managed instance group's auto-healing policy to identify instances that are no longer responsive on port 80.
- **Autoscaler (`google_compute_region_autoscaler.backend_autoscaler`)**: Dynamically adjusts the number of backend instances according to CPU utilization. This accommodates workload demands efficiently while preventing over-provisioning.
- **Firewall Rule - Allow Health Checks (`google_compute_firewall.allow_health_checks_backend`)**: Allows health checks to probe the backend service to verify its availability. Health checks are necessary for the internal load balancer to route traffic safely.
- **Firewall Rule - Allow Frontend to Backend (`google_compute_firewall.allow_frontend_to_backend`)**: Enforces network boundary security by explicitly permitting traffic to the backend only when it originates from the frontend subnet.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `region` | Region for backend resources. | `string` | required |
| `vpc_id` | The ID of the VPC. | `string` | required |
| `subnet_id` | The ID of the subnet for backend instances. | `string` | required |
| `frontend_subnet_cidr` | The CIDR block of the frontend subnet to allow access. | `string` | required |
| `machine_type` | Machine type for backend instances. | `string` | `"e2-micro"` |
| `min_replicas` | Minimum number of instances in backend MIG. | `number` | `2` |
| `max_replicas` | Maximum number of instances in backend MIG. | `number` | `5` |

## Outputs

| Name | Description |
|------|-------------|
| `instance_group` | The instance group of the backend MIG. Required for internal load balancer configuration. |
