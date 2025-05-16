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
  default     = 2
}

variable "ingress_enable_dashboard" {
  type        = bool
  description = "Whether to enable the Traefik dashboard"
  default     = true
}

variable "ingress_ssl_enabled" {
  type        = bool
  description = "Whether to enable SSL for the ingress controller"
  default     = false
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