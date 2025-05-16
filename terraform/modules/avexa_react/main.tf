locals {
  mongodb_connection_parts = var.mongodb_connection_string != "" ? split("@", var.mongodb_connection_string) : ["", ""]
  mongodb_host_port = length(local.mongodb_connection_parts) > 1 ? split("/", local.mongodb_connection_parts[1])[0] : ""
  mongodb_host = local.mongodb_host_port != "" ? split(":", local.mongodb_host_port)[0] : ""
  
  app_values = {
    replicaCount = var.replica_count
    
    image = {
      repository = var.image_repository
      tag        = var.image_tag
    }
    
    resources = {
      limits = {
        cpu    = var.resource_limits.cpu
        memory = var.resource_limits.memory
      }
    }
    
    ingress = {
      enabled = true
      host    = var.ingress_host
    }
    
    mongodb = {
      connectionString = var.mongodb_connection_string
    }
  }
}

resource "helm_release" "avexa_react" {
  name       = "avexa-react"
  chart      = "${path.module}/../../../charts/avexa-react"
  namespace  = var.namespace
  
  values = [
    yamlencode(local.app_values)
  ]
  
  set_sensitive {
    name  = "mongodb.connectionString"
    value = var.mongodb_connection_string
  }
}