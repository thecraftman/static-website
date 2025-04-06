#!/bin/bash
set -e

# Add cert-manager Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager with CRDs
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.1 \
  --set installCRDs=true

# Wait for cert-manager to be ready
kubectl -n cert-manager wait --for=condition=available deployment --all --timeout=300s

echo "cert-manager installed successfully!"