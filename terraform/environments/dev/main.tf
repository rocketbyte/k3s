module "k3s_infra" {
  source = "../../"
  
  # Raspberry Pi k3s cluster configuration
  kube_config_path = var.kube_config_path
  kube_context     = var.kube_context
  use_kube_exec    = var.use_kube_exec
  
  # Deployment configuration for dev environment
  namespaces       = ["rocket", "monitoring"]
  
  # MongoDB configuration
  mongodb_namespace     = "rocket"
  mongodb_storage_size  = "2Gi"  # Larger for dev testing
  mongodb_enable_auth   = true
  mongodb_replicas      = 1      # Single instance for dev
  mongodb_resource_limits = {
    cpu    = "300m"
    memory = "400Mi"
  }
  
  # Ingress controller configuration
  ingress_namespace       = "rocket"
  ingress_replicas        = 1     # Single instance for dev
  ingress_enable_dashboard = true
  ingress_ssl_enabled     = false # No SSL for dev
  ingress_resource_limits = {
    cpu    = "200m"
    memory = "256Mi"
  }
  
  # Avexa React configuration
  avexa_namespace        = "rocket"
  avexa_replicas         = 1      # Single instance for dev
  avexa_image_repository = "rocketbyte/avexa-react"
  avexa_image_tag        = "dev"  # Use dev tag
  avexa_ingress_host     = "app.rocket.local"
  avexa_resource_limits  = {
    cpu    = "200m"
    memory = "256Mi"
  }
}