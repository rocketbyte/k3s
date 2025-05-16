# Kubernetes cluster configuration
variable "kube_config_path" {
  type        = string
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "kube_context" {
  type        = string
  description = "Kubernetes context to use for the Raspberry Pi k3s cluster"
  default     = ""
}

variable "use_kube_exec" {
  type        = bool
  description = "Whether to use the Kubernetes exec plugin for authentication"
  default     = false
}

# Deployment toggles
variable "deploy_namespaces" {
  type        = bool
  description = "Whether to deploy the namespace resources"
  default     = true
}

variable "deploy_mongodb" {
  type        = bool
  description = "Whether to deploy MongoDB"
  default     = true
}

variable "deploy_ingress" {
  type        = bool
  description = "Whether to deploy the ingress controller"
  default     = true
}

variable "deploy_avexa_react" {
  type        = bool
  description = "Whether to deploy the Avexa React application"
  default     = true
}

# Namespace configuration
variable "namespaces" {
  type        = list(string)
  description = "List of namespaces to create"
  default     = ["rocket"]
}

# MongoDB configuration
variable "mongodb_namespace" {
  type        = string
  description = "Namespace for MongoDB deployment"
  default     = "rocket"
}

variable "mongodb_storage_size" {
  type        = string
  description = "Storage size for MongoDB PVC"
  default     = "1Gi"
}

variable "mongodb_enable_auth" {
  type        = bool
  description = "Whether to enable authentication for MongoDB"
  default     = true
}

variable "mongodb_replicas" {
  type        = number
  description = "Number of MongoDB replicas"
  default     = 1
}

variable "mongodb_resource_limits" {
  type = object({
    cpu    = string
    memory = string
  })
  description = "Resource limits for MongoDB"
  default = {
    cpu    = "500m"
    memory = "512Mi"
  }
}

variable "external_mongodb_connection" {
  type        = string
  description = "External MongoDB connection string if not deploying MongoDB"
  default     = ""
  sensitive   = true
}

# Ingress Controller configuration
variable "ingress_namespace" {
  type        = string
  description = "Namespace for ingress controller deployment"
  default     = "rocket"
}

variable "ingress_replicas" {
  type        = number
  description = "Number of ingress controller replicas"
  default     = 1
}

# Service configuration
variable "ingress_service_type" {
  type        = string
  description = "Type of Kubernetes Service to create"
  default     = "LoadBalancer"
}

variable "ingress_service_annotations" {
  type        = map(string)
  description = "Annotations for the Traefik service"
  default     = {
    "metallb.universe.tf/allow-shared-ip" = "true"
  }
}

# Dashboard configuration
variable "ingress_enable_dashboard" {
  type        = bool
  description = "Whether to enable the Traefik dashboard"
  default     = true
}

variable "ingress_dashboard_secure" {
  type        = bool
  description = "Whether to secure the Traefik dashboard"
  default     = false
}

# SSL configuration
variable "ingress_ssl_enabled" {
  type        = bool
  description = "Whether to enable SSL for the ingress controller"
  default     = true
}

variable "ingress_ssl_redirect" {
  type        = bool
  description = "Whether to redirect HTTP to HTTPS"
  default     = true
}

variable "ingress_ssl_email" {
  type        = string
  description = "Email to use for Let's Encrypt"
  default     = "admin@example.com"
}

# Resource management
variable "ingress_resource_requests" {
  type = object({
    cpu    = string
    memory = string
  })
  description = "Resource requests for Ingress Controller"
  default = {
    cpu    = "50m"
    memory = "100Mi"
  }
}

variable "ingress_resource_limits" {
  type = object({
    cpu    = string
    memory = string
  })
  description = "Resource limits for ingress controller"
  default = {
    cpu    = "200m"
    memory = "256Mi"
  }
}

# Autoscaling configuration
variable "ingress_enable_autoscaling" {
  type        = bool
  description = "Whether to enable autoscaling for Traefik"
  default     = false
}

variable "ingress_min_replicas" {
  type        = number
  description = "Minimum number of replicas for autoscaling"
  default     = 1
}

variable "ingress_max_replicas" {
  type        = number
  description = "Maximum number of replicas for autoscaling"
  default     = 2
}

variable "ingress_cpu_target" {
  type        = number
  description = "CPU utilization target for autoscaling"
  default     = 80
}

variable "ingress_memory_target" {
  type        = number
  description = "Memory utilization target for autoscaling"
  default     = 80
}

# Storage for Let's Encrypt certificates
variable "ingress_enable_persistence" {
  type        = bool
  description = "Whether to enable persistence for Traefik ACME data"
  default     = true
}

variable "ingress_persistence_size" {
  type        = string
  description = "Size of persistent volume claim"
  default     = "128Mi"
}

variable "ingress_storage_class" {
  type        = string
  description = "Storage class for persistent volume claim"
  default     = ""
}

# Hardware optimization
variable "ingress_node_selector" {
  type        = map(string)
  description = "Node selector for Traefik pods"
  default     = {
    "kubernetes.io/arch" = "arm64"  # For Raspberry Pi 4
  }
}

variable "ingress_tolerations" {
  type        = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  description = "Tolerations for Traefik pods"
  default     = []
}

# Optional: custom version
variable "ingress_traefik_version" {
  type        = string
  description = "Traefik version to deploy"
  default     = "2.10.4"
}

# Additional CLI arguments
variable "ingress_additional_arguments" {
  type        = list(string)
  description = "Additional CLI arguments for Traefik"
  default     = [
    "--log.level=INFO",
    "--api.insecure=true",
    "--metrics.prometheus=true",
    "--providers.kubernetesingress.ingressclass=traefik",
    "--entrypoints.websecure.http.tls=true"
  ]
}

# Avexa React application configuration
variable "avexa_namespace" {
  type        = string
  description = "Namespace for Avexa React deployment"
  default     = "rocket"
}

variable "avexa_replicas" {
  type        = number
  description = "Number of Avexa React replicas"
  default     = 2
}

variable "avexa_image_repository" {
  type        = string
  description = "Docker image repository for Avexa React"
  default     = "rocketbyte/avexa-react"
}

variable "avexa_image_tag" {
  type        = string
  description = "Docker image tag for Avexa React"
  default     = "latest"
}

variable "avexa_ingress_host" {
  type        = string
  description = "Hostname for Avexa React ingress"
  default     = "app.rocket.local"
}

variable "avexa_resource_limits" {
  type = object({
    cpu    = string
    memory = string
  })
  description = "Resource limits for Avexa React"
  default = {
    cpu    = "200m"
    memory = "256Mi"
  }
}