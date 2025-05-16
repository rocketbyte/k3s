resource "random_password" "mongodb_root" {
  length  = 16
  special = false
}

resource "random_password" "mongodb_user" {
  length  = 16
  special = false
}

locals {
  mongodb_values = {
    auth = {
      enabled = var.enable_authentication
      rootPassword = var.enable_authentication ? random_password.mongodb_root.result : ""
      username = var.enable_authentication ? "avexa" : ""
      password = var.enable_authentication ? random_password.mongodb_user.result : ""
      database = "avexa"
    }
    persistence = {
      enabled = true
      size = var.storage_size
    }
    resources = {
      limits = {
        cpu = var.resource_limits.cpu
        memory = var.resource_limits.memory
      }
    }
    replicaCount = var.replica_count
  }
}

resource "helm_release" "mongodb" {
  name       = "mongodb"
  chart      = "${path.module}/../../../charts/mongodb"
  namespace  = var.namespace
  
  values = [
    yamlencode(local.mongodb_values)
  ]
  
  set_sensitive {
    name  = "auth.rootPassword"
    value = var.enable_authentication ? random_password.mongodb_root.result : ""
  }
  
  set_sensitive {
    name  = "auth.password"
    value = var.enable_authentication ? random_password.mongodb_user.result : ""
  }
}