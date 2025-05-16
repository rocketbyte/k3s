output "application_url" {
  description = "URL to access the Avexa React application"
  value       = var.deploy_avexa_react ? module.avexa_react[0].application_url : "Application not deployed"
}

output "mongodb_connection_string" {
  description = "MongoDB connection string"
  value       = var.deploy_mongodb ? module.mongodb[0].connection_string : "MongoDB not deployed"
  sensitive   = true
}

output "ingress_controller_dashboard" {
  description = "Ingress controller dashboard status"
  value       = var.deploy_ingress ? (module.ingress_controller[0].dashboard_enabled ? "Enabled at traefik dashboard" : "Dashboard disabled") : "Ingress controller not deployed"
}

output "deployed_namespaces" {
  description = "List of deployed namespaces"
  value       = var.deploy_namespaces ? var.namespaces : "No namespaces deployed"
}

output "cluster_info" {
  description = "Information about the Kubernetes cluster"
  value = {
    context = var.kube_context != "" ? var.kube_context : "default"
    config  = var.kube_config_path
  }
}