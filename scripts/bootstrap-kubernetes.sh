#!/bin/bash
set -e

echo "Checking Docker Desktop Kubernetes"

# Check if Docker Desktop Kubernetes is running
if ! kubectl cluster-info &> /dev/null; then
    echo "Error: Docker Desktop Kubernetes is not running."
    echo "Please enable Kubernetes in Docker Desktop settings:"
    echo "1. Open Docker Desktop"
    echo "2. Go to Settings > Kubernetes"
    echo "3. Check 'Enable Kubernetes'"
    echo "4. Click 'Apply & Restart'"
    exit 1
fi

echo "Docker Desktop Kubernetes is running"

# Create namespaces for our application
echo "Creating namespaces..."
kubectl create namespace xayn-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace xayn-prod --dry-run=client -o yaml | kubectl apply -f -

echo "Namespaces created"

# Add Traefik Helm repository
echo "Adding Traefik Helm repository..."
helm repo add traefik https://traefik.github.io/charts
helm repo update

echo "Traefik Helm repository added"

echo "Docker Desktop Kubernetes setup complete!"