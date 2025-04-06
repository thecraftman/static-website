variable "website_image" {
  description = "Docker image for the static website"
  type        = string
  default     = "xayn/static-website:latest"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "example.com"
}

variable "use_lets_encrypt" {
  description = "Whether to use Let's Encrypt for production"
  type        = bool
  default     = false
}