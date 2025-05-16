# Install Traefik CRDs before deployment
resource "null_resource" "traefik_crds" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml"
  }
}

# Create ServiceAccount for Traefik
resource "kubernetes_service_account" "traefik" {
  metadata {
    name      = "traefik-ingress-controller"
    namespace = var.namespace
  }
}

# Create ClusterRole for Traefik
resource "kubernetes_cluster_role" "traefik" {
  metadata {
    name = "traefik-ingress-controller"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "secrets", "pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses", "ingressclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses/status"]
    verbs      = ["update"]
  }

  rule {
    api_groups = ["traefik.containo.us", "traefik.io"]
    resources  = ["middlewares", "ingressroutes", "traefikservices", "tlsstores", "tlsoptions"]
    verbs      = ["get", "list", "watch"]
  }
}

# Create ClusterRoleBinding for Traefik
resource "kubernetes_cluster_role_binding" "traefik" {
  metadata {
    name = "traefik-ingress-controller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.traefik.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.traefik.metadata[0].name
    namespace = var.namespace
  }
}

# Create Service for Traefik
resource "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "traefik"
    }

    port {
      port        = 80
      target_port = 80
      name        = "web"
    }

    port {
      port        = 443
      target_port = 443
      name        = "websecure"
    }

    port {
      port        = 7000
      target_port = 7000
      name        = "dashboard"
    }

    type = var.service_type
  }
}

# Create Traefik Deployment
resource "kubernetes_deployment" "traefik" {
  metadata {
    name      = "traefik"
    namespace = var.namespace
    labels = {
      app = "traefik"
    }
  }

  spec {
    replicas = var.replica_count

    selector {
      match_labels = {
        app = "traefik"
      }
    }

    template {
      metadata {
        labels = {
          app = "traefik"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.traefik.metadata[0].name

        container {
          image = "traefik:v2.9.8"
          name  = "traefik"

          port {
            container_port = 80
            name           = "web"
          }

          port {
            container_port = 443
            name           = "websecure"
          }

          port {
            container_port = 7000
            name           = "dashboard"
          }

          args = [
            "--api=true",
            "--api.dashboard=true",
            "--api.insecure=true",
            "--entrypoints.web.address=:80",
            "--entrypoints.websecure.address=:443",
            "--entrypoints.dashboard.address=:7000",
            "--providers.kubernetesingress=true",
            "--accesslog=true"
          ]

          resources {
            limits = {
              cpu    = var.resource_limits.cpu
              memory = var.resource_limits.memory
            }
            requests = {
              cpu    = var.resource_requests.cpu
              memory = var.resource_requests.memory
            }
          }
        }

        dynamic "toleration" {
          for_each = var.tolerations
          content {
            key      = toleration.value["key"]
            operator = toleration.value["operator"]
            value    = toleration.value["value"]
            effect   = toleration.value["effect"]
          }
        }

        node_selector = var.node_selector
      }
    }
  }

  depends_on = [
    null_resource.traefik_crds,
    kubernetes_cluster_role_binding.traefik
  ]
}