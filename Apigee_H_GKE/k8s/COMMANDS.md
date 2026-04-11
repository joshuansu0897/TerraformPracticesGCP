# How to connect to the cluster

```bash
gcloud container clusters get-credentials apigee-cluster-<region_1> --region <region_1> --project <project_id>

gcloud container clusters get-credentials apigee-cluster-us-west1 --region us-west1 --project my-default-project-483019

# now we can use kubectl
kubectl get nodes
```

```bash
gcloud container clusters get-credentials apigee-cluster-<region_2> --region <region_2> --project <project_id>

gcloud container clusters get-credentials apigee-cluster-us-central1 --region us-central1 --project my-default-project-483019

# now we can use kubectl
kubectl get nodes   
```

# Create cluster role binding, need to be executed in both clusters
```bash
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)
```
