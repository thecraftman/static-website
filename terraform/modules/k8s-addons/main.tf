# AWS Load Balancer Controller
module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name = "${var.cluster_name}-aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.aws_load_balancer_controller_irsa_role.iam_role_arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.6.1"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
  }

  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller
  ]
}

# Install cert-manager for Let's Encrypt support
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.13.1"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# Create namespaces for our application
resource "kubernetes_namespace" "xayn_dev" {
  metadata {
    name = "xayn-dev"
  }
}

resource "kubernetes_namespace" "xayn_prod" {
  metadata {
    name = "xayn-prod"
  }
}

# Create secrets for our application
resource "kubernetes_secret" "website_secret_dev" {
  metadata {
    name      = "website-secret"
    namespace = kubernetes_namespace.xayn_dev.metadata[0].name
  }

  data = {
    "secret-value" = var.dev_secret
  }

  type = "Opaque"
}

resource "kubernetes_secret" "website_secret_prod" {
  metadata {
    name      = "website-secret"
    namespace = kubernetes_namespace.xayn_prod.metadata[0].name
  }

  data = {
    "secret-value" = var.prod_secret
  }

  type = "Opaque"
}

# Deploy Traefik to both namespaces
resource "helm_release" "traefik_dev" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  namespace  = kubernetes_namespace.xayn_dev.metadata[0].name
  version    = "24.0.0"
  
  values = [file("${path.module}/traefik-values.yaml")]
  
  depends_on = [
    helm_release.aws_load_balancer_controller
  ]
}

resource "helm_release" "traefik_prod" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  namespace  = kubernetes_namespace.xayn_prod.metadata[0].name
  version    = "24.0.0"
  
  values = [file("${path.module}/traefik-values.yaml")]
  
  depends_on = [
    helm_release.aws_load_balancer_controller
  ]
}

# Create a ClusterIssuer for Let's Encrypt (for the extra credit part)
resource "kubectl_manifest" "cluster_issuer_prod" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.letsencrypt_email}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: alb
YAML

  depends_on = [
    helm_release.cert_manager
  ]
}