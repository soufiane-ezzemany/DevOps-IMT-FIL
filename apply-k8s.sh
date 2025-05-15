#!/bin/bash

# Exit on error
set -e

echo "Applying Kubernetes manifests..."

# Apply database manifests first (PV, PVC, Deployment, Service)
echo "Applying database manifests..."
kubectl apply -f db-service-deployment-volume.yaml

# Wait for database to be ready
#echo "Waiting for database to be ready..."
#kubectl wait --for=condition=ready pod -l app=db --timeout=60s

# Apply Redis manifests
echo "Applying Redis manifests..."
kubectl apply -f redis-service-deployment.yaml

# Apply Worker manifests
echo "Applying Worker manifests..."
kubectl apply -f worker/deployment.yaml

# Apply Vote manifests
echo "Applying Vote manifests..."
kubectl apply -f vote/deployment.yaml
kubectl apply -f vote/service.yaml

# Apply Result manifests
echo "Applying Result manifests..."
kubectl apply -f result/deployment.yaml
kubectl apply -f result/service.yaml

# Apply seed job
echo "Applying seed job..."
kubectl apply -f seed-data/job.yaml

echo "All manifests have been applied successfully!"

echo "Launching minikube tunnel"

minikube tunnel