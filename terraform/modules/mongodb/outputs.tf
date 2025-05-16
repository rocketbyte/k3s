output "host" {
  description = "MongoDB host address"
  value       = "mongodb.${var.namespace}.svc.cluster.local"
}

output "port" {
  description = "MongoDB port"
  value       = 27017
}

output "username" {
  description = "MongoDB username"
  value       = var.enable_authentication ? "avexa" : ""
  sensitive   = true
}

output "password" {
  description = "MongoDB password"
  value       = var.enable_authentication ? random_password.mongodb_user.result : ""
  sensitive   = true
}

output "database" {
  description = "MongoDB database name"
  value       = "avexa"
}

output "connection_string" {
  description = "MongoDB connection string"
  value       = var.enable_authentication ? "mongodb://avexa:${random_password.mongodb_user.result}@mongodb.${var.namespace}.svc.cluster.local:27017/avexa" : "mongodb://mongodb.${var.namespace}.svc.cluster.local:27017/avexa"
  sensitive   = true
}