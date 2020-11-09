output "resource_group_name" {
  description = "The name of the resource group in which resources are created"  
  value       = var.resource_group_name
}

output "administrator_login" {
  description = "The postgresql instance login for the admin."
  sensitive   = true
  value       = var.administrator_login
}

output "administrator_password" {
  description = "The password for the admin account of the postgresql instance."
  sensitive   = true
  value       = (var.create_mode == "Default" ? random_password.admin[0].result : null)
}

output "name" {
  description = "The Name of the postgresql instance."
  value       = azurerm_postgresql_server.instance.name
}

output "id" {
  description = "The ID of the postgresql instance."
  value       = azurerm_postgresql_server.instance.id
}

output "fqdn" {
  description = "The fully qualified domain name of the instance Azure SQL Server" 
  value       = azurerm_postgresql_server.instance.fqdn
}

