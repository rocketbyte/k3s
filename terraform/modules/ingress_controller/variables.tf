variable "namespace" {
  type        = string
  description = "Namespace for Ingress Controller deployment"
  default     = "rocket"
}

variable "replica_count" {
  type        = number
  description = "Number of Ingress Controller replicas"
  default     = 2
}

variable "enable_dashboard" {
  type        = bool
  description = "Whether to enable the Traefik dashboard"
  default     = true
}

variable "ssl_enabled" {
  type        = bool
  description = "Whether to enable SSL for the ingress controller"
  default     = false
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