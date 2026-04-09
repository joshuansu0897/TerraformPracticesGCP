# How to connect to the cluster

```bash
gcloud container clusters get-credentials apigee-cluster-west --region us-west1 --project my-default-project-483019

# now we can use kubectl
kubectl get nodes
```

```bash
gcloud container clusters get-credentials apigee-cluster-east --region us-central1 --project my-default-project-483019

# now we can use kubectl
kubectl get nodes   
```

