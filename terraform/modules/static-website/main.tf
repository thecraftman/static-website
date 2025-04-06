resource "kubernetes_deployment" "static_website_dev" {
  metadata {
    name      = "static-website"
    namespace = "xayn-dev"
    labels = {
      app = "static-website"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "static-website"
      }
    }

    template {
      metadata {
        labels = {
          app = "static-website"
        }
      }

      spec {
        container {
          name  = "static-website"
          image = var.website_image
          
          env {
            name  = "ENVIRONMENT"
            value = "dev"
          }
          
          env {
            name = "SECRET_VALUE"
            value_from {
              secret_key_ref {
                name = "website-secret"
                key  = "secret-value"
              }
            }
          }
          
          port {
            container_port = 80
          }
          
          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          
          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            
            initial_delay_seconds = 5
            period_seconds        = 5
          }
          
          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "static_website_prod" {
  metadata {
    name      = "static-website"
    namespace = "xayn-prod"
    labels = {
      app = "static-website"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "static-website"
      }
    }

    template {
      metadata {
        labels = {
          app = "static-website"
        }
      }

      spec {
        container {
          name  = "static-website"
          image = var.website_image
          
          env {
            name  = "ENVIRONMENT"
            value = "prod"
          }
          
          env {
            name = "SECRET_VALUE"
            value_from {
              secret_key_ref {
                name = "website-secret"
                key  = "secret-value"
              }
            }
          }
          
          port {
            container_port = 80
          }
          
          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            
            initial_delay_seconds = 10
            period_seconds        = 10
          }
          
          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            
            initial_delay_seconds = 5
            period_seconds        = 5
          }
          
          resources {
            limits = {
              cpu    = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "static_website_dev" {
  metadata {
    name      = "static-website"
    namespace = "xayn-dev"
  }

  spec {
    selector = {
      app = "static-website"
    }
    
    port {
      port        = 80
      target_port = 80
    }
    
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "static_website_prod" {
  metadata {
    name      = "static-website"
    namespace = "xayn-prod"
  }

  spec {
    selector = {
      app = "static-website"
    }
    
    port {
      port        = 80
      target_port = 80
    }
    
    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "static_website_dev" {
  metadata {
    name      = "static-website"
    namespace = "xayn-dev"
    annotations = {
      "kubernetes.io/ingress.class"             = "alb"
      "alb.ingress.kubernetes.io/scheme"        = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"   = "ip"
      "alb.ingress.kubernetes.io/listen-ports"  = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"  = "443"
    }
  }

  spec {
    rule {
      host = "dev.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "static-website"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    
    tls {
      secret_name = "dev-tls-secret"
    }
  }
}

resource "kubernetes_ingress_v1" "static_website_prod" {
  metadata {
    name      = "static-website"
    namespace = "xayn-prod"
    annotations = {
      "kubernetes.io/ingress.class"             = "alb"
      "alb.ingress.kubernetes.io/scheme"        = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"   = "ip"
      "alb.ingress.kubernetes.io/listen-ports"  = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"  = "443"
      "cert-manager.io/cluster-issuer"          = var.use_lets_encrypt ? "letsencrypt-prod" : null
    }
  }

  spec {
    rule {
      host = var.domain_name
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "static-website"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    
    tls {
      secret_name = var.use_lets_encrypt ? "prod-lets-encrypt-tls" : "prod-tls-secret"
    }
  }
}