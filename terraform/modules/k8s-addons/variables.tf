variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "dev_secret" {
  description = "Secret value for dev environment"
  type        = string
  default     = "dev-secret-value"
}

variable "prod_secret" {
  description = "Secret value for prod environment"
  type        = string
  default     = "prod-secret-value"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "example.com"
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt"
  type        = string
  default     = "admin@example.com"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}