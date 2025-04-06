#!/bin/bash
set -e

# Check if environment argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <environment> [--build]"
    echo "  environment: dev or prod"
    echo "  --build: build the Docker image (optional)"
    exit 1
fi

ENVIRONMENT=$1
BUILD_FLAG=$2
NAMESPACE="xayn-$ENVIRONMENT"

echo "Deploying to $ENVIRONMENT environment..."

# Build Docker image if requested
if [ "$BUILD_FLAG" == "--build" ]; then
    echo "Building Docker image..."
    cd src/website
    docker build -t xayn/static-website:latest .
    cd ../..
    echo "Docker image built"
fi

# Apply secrets
echo "Applying secrets..."
kubectl apply -f kubernetes/$ENVIRONMENT/secrets.yaml
echo "Secrets applied"

# Install/upgrade our static website
echo "Deploying static website..."
helm upgrade --install static-website charts/static-website \
  --namespace $NAMESPACE \
  --values kubernetes/$ENVIRONMENT/values.yaml
echo "Static website deployed"

echo "Deployment to $ENVIRONMENT completed successfully!"
echo ""
echo "To access the application:"
echo "1. Make sure you have these entries in your /etc/hosts file:"
echo "   127.0.0.1 dev.static-website.local"
echo "   127.0.0.1 static-website.local"
echo ""
echo "2. Access the website at:"
if [ "$ENVIRONMENT" == "dev" ]; then
    echo "   https://dev.static-website.local"
else
    echo "   https://static-website.local"
fi