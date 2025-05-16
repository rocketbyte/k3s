variable "namespace" {
  type        = string
  description = "Namespace for Ingress Controller deployment"
  default     = "rocket"
}

variable "replica_count" {
  type        = number
  description = "Number of Ingress Controller replicas"
  default     = 1
}

variable "service_type" {
  type        = string
  description = "Type of Kubernetes Service to create"
  default     = "LoadBalancer"
}

variable "service_annotations" {
  type        = map(string)
  description = "Annotations for the Traefik service"
  default     = {
    "metallb.universe.tf/allow-shared-ip" = "true"
  }
}

variable "enable_dashboard" {
  type        = bool
  description = "Whether to enable the Traefik dashboard"
  default     = true
}

variable "dashboard_secure" {
  type        = bool
  description = "Whether to secure the Traefik dashboard"
  default     = false
}

variable "ssl_enabled" {
  type        = bool
  description = "Whether to enable SSL for the ingress controller"
  default     = true
}

variable "ssl_redirect" {
  type        = bool
  description = "Whether to redirect HTTP to HTTPS"
  default     = true
}

variable "ssl_email" {
  type        = string
  description = "Email to use for Let's Encrypt"
  default     = "admin@example.com"
}

variable "resource_requests" {
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

variable "resource_limits" {
  type = object({
    cpu    = string
    memory = string
  })
  description = "Resource limits for Ingress Controller"
  default = {
    cpu    = "200m"
    memory = "256Mi"
  }
}

variable "enable_autoscaling" {
  type        = bool
  description = "Whether to enable autoscaling for Traefik"
  default     = false
}

variable "min_replicas" {
  type        = number
  description = "Minimum number of replicas for autoscaling"
  default     = 1
}

variable "max_replicas" {
  type        = number
  description = "Maximum number of replicas for autoscaling"
  default     = 2
}

variable "cpu_target_utilization" {
  type        = number
  description = "CPU utilization target for autoscaling"
  default     = 80
}

variable "memory_target_utilization" {
  type        = number
  description = "Memory utilization target for autoscaling"
  default     = 80
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for Traefik pods"
  default     = {
    "kubernetes.io/arch" = "arm64" 
  }
}

variable "tolerations" {
  type        = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  description = "Tolerations for Traefik pods"
  default     = []
}

variable "enable_persistence" {
  type        = bool
  description = "Whether to enable persistence for Traefik ACME data"
  default     = true
}

variable "persistence_size" {
  type        = string
  description = "Size of persistent volume claim"
  default     = "128Mi"
}

variable "storage_class" {
  type        = string
  description = "Storage class for persistent volume claim"
  default     = ""
}

variable "traefik_version" {
  type        = string
  description = "Traefik version to deploy"
  default     = "2.10.4"
}

variable "additional_arguments" {
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