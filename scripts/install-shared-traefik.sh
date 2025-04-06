#!/bin/bash
set -e

echo "Installing shared Traefik for all environments..."

# Create a dedicated namespace for Traefik
kubectl create namespace traefik --dry-run=client -o yaml | kubectl apply -f -

# Install Traefik in its own namespace
helm upgrade --install traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  --values charts/traefik-values.yaml

echo "Shared Traefik installed successfully!"