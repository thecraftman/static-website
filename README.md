# Static Website Deployment

A Kubernetes-based static website deployment system with both local and cloud options.

## Overview

This project provides:

- Static website hosting on Kubernetes with environment variable injection
- Self-signed HTTPS and secret management
- Separate dev/prod environments
- Local deployment using Docker Desktop Kubernetes
- Cloud deployment using AWS EKS via Terraform

## Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl
- Helm
- Git
- AWS CLI (for EKS deployment)
- Terraform (for EKS deployment)


## Local Deployment

```bash
# 1. Clone the repository
git clone https://github.com/thecraftman/static-website.git
cd static-website

# 2. Bootstrap the environment
./scripts/bootstrap-kubernetes.sh

# 3. Generate self-signed certificates
./scripts/generate-certificates.sh

# 4. Add hosts file entries
# Add to /etc/hosts (Linux/Mac) or C:\Windows\System32\drivers\etc\hosts (Windows):
# 127.0.0.1 dev.static-website.local
# 127.0.0.1 static-website.local

# 5. Deploy to development
./scripts/deploy.sh dev --build

# 6. Deploy to production
./scripts/deploy.sh prod
```

### Access at:

- Development: https://dev.static-website.local
- Production: https://static-website.local