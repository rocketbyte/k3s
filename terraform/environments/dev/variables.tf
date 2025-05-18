variable "kube_config_path" {
  type        = string
  description = "Path to the kubeconfig file for Raspberry Pi k3s cluster"
  default     = "~/.kube/config"
}

variable "kube_context" {
  type        = string
  description = "Kubernetes context to use for the Raspberry Pi k3s cluster"
  default     = "" # Set this to your Raspberry Pi k3s cluster context
}

variable "use_kube_exec" {
  type        = bool
  description = "Whether to use the Kubernetes exec plugin for authentication to the Raspberry Pi cluster"
  default     = true
}