module "k3s_infra" {
  source = "../../"

  # Raspberry Pi k3s cluster configuration
  kube_config_path = var.kube_config_path
  kube_context     = var.kube_context
  use_kube_exec    = var.use_kube_exec

  # Deployment configuration for dev environment
  namespaces = ["rocket"]

  # Disable MongoDB as it's not compatible with ARMv8 on Raspberry Pi
  deploy_mongodb = false

  # Ingress controller configuration for Raspberry Pi
  ingress_namespace    = "rocket"
  ingress_replicas     = 1 # Single instance is enough for Raspberry Pi
  ingress_service_type = "LoadBalancer"
  ingress_service_annotations = {
    "metallb.universe.tf/allow-shared-ip" = "true"
  }
  ingress_enable_dashboard = true
  ingress_dashboard_secure = false # Allow easy access to dashboard during development
  ingress_ssl_enabled      = true  # Enable SSL for security
  ingress_ssl_redirect     = true
  ingress_ssl_email        = "admin@example.com" # Change to your email

  # Resource tuning for Raspberry Pi
  ingress_resource_requests = {
    cpu    = "50m"
    memory = "100Mi"
  }
  ingress_resource_limits = {
    cpu    = "200m"
    memory = "256Mi"
  }

  # Disable autoscaling for Raspberry Pi to conserve resources
  ingress_enable_autoscaling = false
  ingress_min_replicas       = 1
  ingress_max_replicas       = 2

  # Disable persistence initially to get basic functionality working
  ingress_enable_persistence = false
  ingress_persistence_size   = "128Mi"

  # Optimization for Raspberry Pi (ARM architecture)
  ingress_node_selector = {
    "kubernetes.io/arch" = "arm64" # For Raspberry Pi 4
  }

  # Enable Avexa React with ARM-compatible image from Docker Hub
  deploy_avexa_react = true
  avexa_namespace    = "rocket"
  avexa_replicas     = 1
  # Using starlingilcruz/avexa but we need an ARM-compatible image
  avexa_image_repository = "docker.io/starlingilcruz/avexa"
  avexa_image_tag        = "latest" # Would be the ARM-compatible version
  avexa_ingress_host     = "app.rocket.local"
  avexa_resource_limits = {
    cpu    = "200m"
    memory = "256Mi"
  }
  # Optimization for Raspberry Pi (ARM architecture)
  avexa_node_selector = {
    "kubernetes.io/arch" = "arm64" # For Raspberry Pi 4
  }
}