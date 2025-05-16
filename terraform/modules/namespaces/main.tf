variable "namespaces" {
  type        = list(string)
  description = "List of namespaces to create"
  default     = ["rocket"]
}

resource "kubernetes_namespace" "namespaces" {
  for_each = toset(var.namespaces)
  
  metadata {
    name = each.key
    
    labels = {
      name        = each.key
      managed-by  = "terraform"
    }
  }
}