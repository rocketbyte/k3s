variable "namespace" {
  type        = string
  description = "Namespace for Avexa React deployment"
  default     = "rocket"
}

variable "replica_count" {
  type        = number
  description = "Number of Avexa React replicas"
  default     = 2
}

variable "image_repository" {
  type        = string
  description = "Docker image repository for Avexa React"
  default     = "rocketbyte/avexa-react"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag for Avexa React"
  default     = "latest"
}

variable "node_selector" {
  type        = map(string)
  description = "Node selector for Avexa React pods"
  default     = {}
}

variable "ingress_host" {
  type        = string
  description = "Hostname for Avexa React ingress"
  default     = "app.rocket.local"
}

variable "resource_limits" {
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