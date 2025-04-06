variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "xayn"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "xayn-eks-prod"  # Production cluster name
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.28"
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.large"  # Larger instance type for production
}

variable "min_nodes" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
}

variable "desired_nodes" {
  description = "Desired number of nodes"
  type        = number
  default     = 3  # More nodes for production
}

variable "max_nodes" {
  description = "Maximum number of nodes"
  type        = number
  default     = 6  # Higher maximum for production
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "example.com"  # Production domain without subdomain
}

variable "website_image" {
  description = "Docker image for the static website"
  type        = string
  default     = "xayn/static-website:latest"
}

variable "dev_secret" {
  description = "Secret value for dev environment"
  type        = string
  default     = "dev-secret-value"
  sensitive   = true
}

variable "prod_secret" {
  description = "Secret value for prod environment"
  type        = string
  default     = "prod-secret-value"
  sensitive   = true
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt"
  type        = string
  default     = "admin@example.com"
}

variable "use_lets_encrypt" {
  description = "Whether to use Let's Encrypt for production"
  type        = bool
  default     = true  # Enable Let's Encrypt by default for production
}