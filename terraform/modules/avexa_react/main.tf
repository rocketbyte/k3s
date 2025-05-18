locals {
  app_values = {
    app = {
      name = "avexa-react"
      image = {
        repository = var.image_repository
        tag        = var.image_tag
        pullPolicy = "Always"
      }
      port = 80
    }
    
    deployment = {
      replicas = var.replica_count
      resources = {
        requests = {
          cpu    = "50m"  # Reduced for Raspberry Pi
          memory = "100Mi"
        }
        limits = {
          cpu    = var.resource_limits.cpu
          memory = var.resource_limits.memory
        }
      }
      nodeSelector = var.node_selector
    }
    
    ingress = {
      enabled = true
      className = "traefik"
      hosts = [
        {
          host = var.ingress_host
          paths = [
            {
              path = "/"
              pathType = "Prefix"
            }
          ]
        }
      ]
      tls = [
        {
          secretName = "avexa-tls"
          hosts = [var.ingress_host]
        }
      ]
    }
    
    # Simplified security context for maximum Raspberry Pi compatibility
    securityContext = {
      pod = {}  # Empty means use default
      container = {}  # Empty means use default
    }
    
    # Simplified health checks for fast startup
    healthcheck = {
      livenessProbe = {
        enabled = true
        initialDelaySeconds = 10
        periodSeconds = 10
        timeoutSeconds = 5
        failureThreshold = 6
        successThreshold = 1
        path = "/"
      }
      readinessProbe = {
        enabled = true
        initialDelaySeconds = 5
        periodSeconds = 10
        timeoutSeconds = 5
        failureThreshold = 6
        successThreshold = 1
        path = "/"
      }
    }
    
    # React-specific environment variables
    env = [
      {
        name = "NODE_ENV"
        value = "production"
      }
    ]
  }
}

resource "helm_release" "avexa_react" {
  name       = "avexa-react"
  chart      = "${path.module}/../../../charts/avexa-react"
  namespace  = var.namespace
  
  values = [
    yamlencode(local.app_values)
  ]
}