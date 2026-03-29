# GCP Terraform Examples

This repository contains examples of Terraform configurations for Google Cloud Platform (GCP). These examples cover various GCP services and resources, providing a starting point for users to learn and implement infrastructure as code using Terraform on GCP.

## Getting Started
To get started with these examples, follow the instructions below:
1. **Install Terraform** (`used: Terraform v1.14.8`): Make sure you have Terraform installed on your machine. You can download it from the [Terraform website](https://developer.hashicorp.com/terraform/install).
2. **Install Google Cloud SDK**: Install the Google Cloud SDK to interact with GCP services. You can download it from the [Google Cloud SDK website](https://cloud.google.com/sdk/docs/install).
   ```
   used:
   - Google Cloud SDK 562.0.0
   - bq 2.1.30
   - core 2026.03.23
   - gcloud-crc32c 1.0.0
   - gsutil 5.36
   ```
3. **Set Up User Authentication**: Authenticate your Google Cloud account using the following command:
   ```bash
   gcloud auth application-default login
   ```

## Examples
The repository includes the following examples:
- `MIG_ManagedInstanceGroup`: Example of creating a Managed Instance Group (MIG) with a load balancer.
