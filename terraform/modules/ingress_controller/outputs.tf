output "ingress_class" {
  description = "Ingress class name for use with ingress resources"
  value       = "traefik"
}

output "ingress_service_name" {
  description = "Name of the ingress controller service"
  value       = kubernetes_service.traefik.metadata[0].name
}

output "dashboard_enabled" {
  description = "Whether the ingress controller dashboard is enabled"
  value       = var.enable_dashboard
}

output "dashboard_port" {
  value       = 7000
  description = "Port for the Traefik dashboard"
}

output "deployment_name" {
  value       = kubernetes_deployment.traefik.metadata[0].name
  description = "Name of the Traefik deployment"
}