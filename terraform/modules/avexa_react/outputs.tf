output "application_url" {
  description = "URL to access the Avexa React application"
  value       = "http://${var.ingress_host}"
}

output "replica_count" {
  description = "Number of Avexa React replicas deployed"
  value       = var.replica_count
}

output "image_details" {
  description = "Details about the deployed image"
  value       = "${var.image_repository}:${var.image_tag}"
}