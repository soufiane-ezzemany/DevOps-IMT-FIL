#!/bin/bash

# Exit on error
set -e

# Liste des répertoires contenant un Dockerfile
services=("vote" "result" "worker" "seed-data")

# Parcours des services pour construire et charger les images
for service in "${services[@]}"; do
  echo "Building Docker image for $service..."

  # Construire l'image Docker
  docker build -t "$service:latest"
  } "./$service"

  echo "Loading $service:latest into Minikube..."

  # Charger l'image dans Minikube
  minikube image load "$service:latest"
done

echo "All images have been built and loaded into Minikube successfully!"