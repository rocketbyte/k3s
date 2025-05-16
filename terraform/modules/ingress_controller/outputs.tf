output "ingress_class" {
  description = "Ingress class name for use with ingress resources"
  value       = "traefik"
}

output "ingress_service_name" {
  description = "Name of the ingress controller service"
  value       = "ingress-controller"
}

output "dashboard_enabled" {
  description = "Whether the ingress controller dashboard is enabled"
  value       = var.enable_dashboard
}