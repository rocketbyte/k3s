variable "namespace" {
  type        = string
  description = "Namespace for MongoDB deployment"
  default     = "rocket"
}

variable "storage_size" {
  type        = string
  description = "Storage size for MongoDB PVC"
  default     = "1Gi"
}

variable "enable_authentication" {
  type        = bool
  description = "Whether to enable authentication for MongoDB"
  default     = true
}

variable "replica_count" {
  type        = number
  description = "Number of MongoDB replicas"
  default     = 1
}

variable "resource_limits" {
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