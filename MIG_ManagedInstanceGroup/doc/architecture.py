# https://diagrams.mingrammer.com/
from diagrams import Diagram, Cluster, Edge
from diagrams.gcp.compute import ComputeEngine
from diagrams.gcp.network import LoadBalancing, NAT, Router, FirewallRules, VPC
from diagrams.gcp.security import IAP
from diagrams.onprem.client import Users
from diagrams.onprem.network import Internet

# --- DIAGRAM 1: Application Architecture ---
# Contains: LBs, MIGs, VPC, Regions, and Subnets
with Diagram("Application Architecture", filename="mig_application_architecture", show=False, direction="LR"):
    users = Users("End Users")

    with Cluster("Google Cloud Platform"):
        frontend_lb = LoadBalancing("Global HTTP(S) LB\n(frontend-lb-ip)")

        with Cluster("VPC Network (vpc-network)"):
            with Cluster("Region Deployment"):
                with Cluster("Frontend Subnet (frontend-subnet)"):
                    with Cluster("Frontend MIG"):
                        frontend_mig = [ComputeEngine("frontend-inst-1"),
                                        ComputeEngine("frontend-inst-2")]

                with Cluster("Backend Subnet (backend-subnet)"):
                    internal_lb = LoadBalancing("Internal TCP LB\n(backend-forwarding-rule)")
                    with Cluster("Backend MIG"):
                        backend_mig = [ComputeEngine("backend-inst-1"),
                                       ComputeEngine("backend-inst-2")]

    # Core Application Ingress Traffic Flow
    users >> Edge(color="darkblue", label="HTTPS") >> frontend_lb
    
    frontend_lb >> frontend_mig
    for fe in frontend_mig:
        fe >> Edge(color="darkgreen") >> internal_lb
        
    internal_lb >> backend_mig


# --- DIAGRAM 2: Routing Traffic Network ---
# Contains: Firewall rules, NAT Gateway, Subnets, and IAP
with Diagram("Routing Traffic Network", filename="mig_routing_network", show=True, direction="TB"):
    admins = Users("System Administrators")
    internet = Internet("Public Internet")
    health_checks = Users("GCP Health Checkers")

    with Cluster("Google Cloud Platform"):
        iap = IAP("Identity-Aware Proxy")

        with Cluster("VPC Network (vpc-network)"):
            
            with Cluster("Network & Security Services"):
                nat_router = Router("Cloud Router\n(nat-router)")
                nat_gw = NAT("Cloud NAT\n(nat-gateway)")
                nat_router - nat_gw

                fw_iap = FirewallRules("allow-ssh-iap\n(TCP 22)")
                fw_fe_hc = FirewallRules("allow-hc-frontend\n(TCP 80)")
                fw_be_hc = FirewallRules("allow-hc-backend\n(TCP 80)")
                fw_fe_to_be = FirewallRules("allow-frontend-to-backend\n(TCP 80)")
            
            with Cluster("Region Deployment"):
                with Cluster("Frontend Subnet (frontend-subnet)"):
                    frontend_instances = ComputeEngine("Frontend Instances")
                
                with Cluster("Backend Subnet (backend-subnet)"):
                    backend_instances = ComputeEngine("Backend Instances")

    # Routing, Firewall and Security flows
    
    # IAP Admin access (SSH)
    admins >> Edge(color="purple", label="SSH") >> iap
    iap >> Edge(color="purple") >> fw_iap
    
    fw_iap >> Edge(color="purple") >> frontend_instances
    fw_iap >> Edge(color="purple") >> backend_instances

    # Health Check Firewall Routing (GCP Health Checkers)
    health_checks >> Edge(color="darkgreen") >> fw_fe_hc >> Edge(color="darkgreen") >> frontend_instances
    health_checks >> Edge(color="darkgreen") >> fw_be_hc >> Edge(color="darkgreen") >> backend_instances

    # Internal VPC Routing via Firewalls
    frontend_instances >> Edge(color="blue") >> fw_fe_to_be >> Edge(color="blue") >> backend_instances

    # Outbound Traffic via NAT for private instances
    frontend_instances >> Edge(style="dashed", color="gray") >> nat_gw
    backend_instances >> Edge(style="dashed", color="gray") >> nat_gw
    
    nat_gw >> Edge(style="dashed", color="gray") >> internet
