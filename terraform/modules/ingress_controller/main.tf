locals {
  ingress_values = {
    deployment = {
      replicas = var.replica_count
    }
    resources = {
      limits = {
        cpu = var.resource_limits.cpu
        memory = var.resource_limits.memory
      }
    }
    dashboard = {
      enabled = var.enable_dashboard
    }
    ssl = {
      enabled = var.ssl_enabled
    }
  }
}

resource "helm_release" "ingress_controller" {
  name       = "ingress-controller"
  chart      = "${path.module}/../../../charts/ingress-controller"
  namespace  = var.namespace
  
  values = [
    yamlencode(local.ingress_values)
  ]
}