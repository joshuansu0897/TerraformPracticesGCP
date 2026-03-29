# Frontend Module

This module provisions the frontend tier of our application, utilizing Managed Instance Groups (MIGs) and autoscaling configured for high availability and performance.

## Resources and Their Purpose

- **Instance Template (`google_compute_instance_template.frontend_template`)**: Acts as the blueprint for our frontend virtual machines. It defines the machine type, the OS image, networking details, and the startup script so that any instance spawned from this template is identically configured to serve our frontend application.
- **Regional Managed Instance Group (`google_compute_region_instance_group_manager.frontend_mig`)**: Manages the lifecycle of our frontend instances across multiple zones in the region. It ensures that the specified number of instances are running and automatically replaces failed ones, ensuring high availability.
- **Autoscaler (`google_compute_region_autoscaler.frontend_autoscaler`)**: Monitors the CPU utilization of the MIG and automatically scales the number of running frontend instances up or down. This ensures we can handle traffic spikes while optimizing cost during low usage.
- **Firewall Rule - Allow Health Checks (`google_compute_firewall.allow_health_checks`)**: Allows Google Cloud's health check probes to connect to the frontend instances. Without this, the load balancer would consider the instances unhealthy and stop forwarding traffic to them.

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `region` | Region for frontend resources. | `string` | required |
| `vpc_id` | The ID of the VPC. | `string` | required |
| `subnet_id` | The ID of the subnet for frontend instances. | `string` | required |
| `machine_type` | Machine type for frontend instances. | `string` | `"e2-micro"` |
| `min_replicas` | Minimum number of instances in frontend MIG. | `number` | `2` |
| `max_replicas` | Maximum number of instances in frontend MIG. | `number` | `5` |

## Outputs

| Name | Description |
|------|-------------|
| `instance_group` | The instance group of the frontend MIG. Required for load balancer configuration. |
