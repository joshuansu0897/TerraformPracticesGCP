# MIG_ManagedInstanceGroup

In this project, we will create a two-tier application using Google Cloud's **Managed Instance Groups** (**MIGs**). The application will consist of a `frontend` and a `backend`, each running on separate `MIGs`. We will also set up `load balancing` and `auto-scaling` to ensure high availability and performance.

# Frontend MIG
- The `frontend MIG` will host the user interface of our application. It will be configured to automatically scale based on the incoming traffic and `CPU utilization`. We will use a `load balancer` to distribute traffic across the instances in the `frontend MIG`.

# Backend MIG
- The `backend MIG` will host the application logic and database. It will be configured to automatically scale based on the incoming traffic and `CPU utilization`. The `backend MIG` will be connected to the `frontend MIG` through a private network, ensuring secure communication between the two tiers.

# Load Balancing
- We will set up a `load balancer` to distribute incoming traffic. The `load balancer` will be configured to perform health checks on the instances, ensuring that traffic is only sent to healthy instances (`frontend MIG` and `backend MIG`).
- We will also configure the `load balancer` to use a global IP address, allowing users to access the application from anywhere in the world (`frontend MIG`).

# Auto-Scaling
- Both the `frontend MIG` and `backend MIG` will be configured to automatically scale based on the load. We will set up `auto-scaling` policies that will add or remove instances based on `CPU utilization` or incoming traffic. This will ensure that our application can handle varying levels of traffic without manual intervention.

# Diagram
Here is a high-level diagram of the architecture:
TODO