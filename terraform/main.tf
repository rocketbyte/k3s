terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
  required_version = ">= 1.0.0"
}

# K3s Raspberry Pi cluster configuration
provider "kubernetes" {
  config_path    = fileexists(var.kube_config_path) ? var.kube_config_path : null
  config_context = var.kube_context
  
  # For accessing a remote k3s cluster
  dynamic "exec" {
    for_each = var.use_kube_exec ? [1] : []
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubectl"
      args        = ["config", "use-context", var.kube_context]
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = fileexists(var.kube_config_path) ? var.kube_config_path : null
    config_context = var.kube_context
    
    # For accessing a remote k3s cluster
    dynamic "exec" {
      for_each = var.use_kube_exec ? [1] : []
      content {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "kubectl"
        args        = ["config", "use-context", var.kube_context]
      }
    }
  }
}

provider "random" {}

# Modular resource deployment
# Resources can be selectively enabled/disabled using variables
module "namespaces" {
  source      = "./modules/namespaces"
  count       = var.deploy_namespaces ? 1 : 0
  namespaces  = var.namespaces
}

module "mongodb" {
  source                 = "./modules/mongodb"
  count                  = var.deploy_mongodb ? 1 : 0
  namespace              = var.mongodb_namespace
  storage_size           = var.mongodb_storage_size
  enable_authentication  = var.mongodb_enable_auth
  replica_count          = var.mongodb_replicas
  resource_limits        = var.mongodb_resource_limits
  depends_on             = [module.namespaces]
}

module "ingress_controller" {
  source                  = "./modules/ingress_controller"
  count                   = var.deploy_ingress ? 1 : 0
  
  # Basic configuration
  namespace               = var.ingress_namespace
  replica_count           = var.ingress_replicas
  
  # Service configuration
  service_type            = var.ingress_service_type
  service_annotations     = var.ingress_service_annotations
  
  # Dashboard configuration
  enable_dashboard        = var.ingress_enable_dashboard
  dashboard_secure        = var.ingress_dashboard_secure
  
  # SSL configuration
  ssl_enabled             = var.ingress_ssl_enabled
  ssl_redirect            = var.ingress_ssl_redirect
  ssl_email               = var.ingress_ssl_email
  
  # Resource management
  resource_requests       = var.ingress_resource_requests
  resource_limits         = var.ingress_resource_limits
  
  # Autoscaling configuration
  enable_autoscaling      = var.ingress_enable_autoscaling
  min_replicas            = var.ingress_min_replicas
  max_replicas            = var.ingress_max_replicas
  cpu_target_utilization  = var.ingress_cpu_target
  memory_target_utilization = var.ingress_memory_target
  
  # Storage for Let's Encrypt certificates
  enable_persistence      = var.ingress_enable_persistence
  persistence_size        = var.ingress_persistence_size
  storage_class           = var.ingress_storage_class
  
  # Hardware optimization
  node_selector           = var.ingress_node_selector
  tolerations             = var.ingress_tolerations
  
  # Optional: custom version
  traefik_version         = var.ingress_traefik_version
  
  # Additional CLI arguments
  additional_arguments    = var.ingress_additional_arguments
  
  depends_on              = [module.namespaces]
}

module "avexa_react" {
  source                   = "./modules/avexa_react"
  count                    = var.deploy_avexa_react ? 1 : 0
  namespace                = var.avexa_namespace
  replica_count            = var.avexa_replicas
  image_repository         = var.avexa_image_repository
  image_tag                = var.avexa_image_tag
  mongodb_connection_string = var.deploy_mongodb ? module.mongodb[0].connection_string : var.external_mongodb_connection
  ingress_host             = var.avexa_ingress_host
  resource_limits          = var.avexa_resource_limits
  depends_on               = [
    module.namespaces,
    module.ingress_controller,
    module.mongodb
  ]
}