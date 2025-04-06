provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
      command     = "aws"
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    command     = "aws"
  }
  load_config_file = false
}

locals {
  tags = {
    Environment = "prod"
    Terraform   = "true"
    Project     = var.project_name
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 3)
  project_name       = var.project_name
  cluster_name       = var.cluster_name
  tags               = local.tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  instance_type      = var.instance_type
  min_nodes          = var.min_nodes
  desired_nodes      = var.desired_nodes
  max_nodes          = var.max_nodes
  tags               = local.tags
}

module "k8s_addons" {
  source = "../../modules/k8s-addons"

  cluster_name      = var.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  dev_secret        = var.dev_secret
  prod_secret       = var.prod_secret
  domain_name       = var.domain_name
  letsencrypt_email = var.letsencrypt_email
  tags              = local.tags

  depends_on = [
    module.eks
  ]
}

module "static_website" {
  source = "../../modules/static-website"

  website_image     = var.website_image
  domain_name       = var.domain_name
  use_lets_encrypt  = var.use_lets_encrypt

  depends_on = [
    module.k8s_addons
  ]
}