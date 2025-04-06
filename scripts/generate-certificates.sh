#!/bin/bash
set -e

# Create directories for certificates
mkdir -p certs/{dev,prod}

# Generate self-signed certificates for dev environment
echo "Generating dev certificates..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/dev/tls.key -out certs/dev/tls.crt \
  -subj "/CN=dev.static-website.local" \
  -addext "subjectAltName = DNS:dev.static-website.local"

# Generate self-signed certificates for prod environment
echo "Generating prod certificates..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/prod/tls.key -out certs/prod/tls.crt \
  -subj "/CN=static-website.local" \
  -addext "subjectAltName = DNS:static-website.local"

# Create Kubernetes TLS secrets
echo "Creating Kubernetes TLS secrets..."
kubectl create secret tls dev-tls-secret \
  --key=certs/dev/tls.key \
  --cert=certs/dev/tls.crt \
  -n xayn-dev \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret tls prod-tls-secret \
  --key=certs/prod/tls.key \
  --cert=certs/prod/tls.crt \
  -n xayn-prod \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Certificates generated and secrets created!"

echo "IMPORTANT: Add the following entries to your /etc/hosts file:"
echo "127.0.0.1 dev.static-website.local"
echo "127.0.0.1 static-website.local"