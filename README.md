# GCP Terraform Examples

This repository contains examples of Terraform configurations for Google Cloud Platform (GCP). These examples cover various GCP services and resources, providing a starting point for users to learn and implement infrastructure as code using Terraform on GCP.

## Getting Started
To get started with these examples, follow the instructions below:
1. **Install Terraform**: Make sure you have Terraform installed on your machine. You can download it from the [Terraform website](https://www.terraform.io/downloads.html).
2. **Install Google Cloud SDK**: Install the Google Cloud SDK to interact with GCP services. You can download it from the [Google Cloud SDK website](https://cloud.google.com/sdk/docs/install).
3. **Set Up User Authentication**: Authenticate your Google Cloud account using the following command:
   ```bash
   gcloud auth application-default login
   ```

## Examples
The repository includes the following examples:
- `MIG_ManagedInstanceGroup`: Example of creating a Managed Instance Group (MIG) with a load balancer.
