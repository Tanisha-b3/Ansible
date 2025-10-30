output "vm_public_ip" {
  description = "Public IP address of the EpicBook VM"
  value       = module.compute.vm_public_ip
}

output "website_url" {
  description = "URL to access EpicBook website"
  value       = "http://${module.compute.vm_public_ip}"
}

output "mysql_fqdn" {
  description = "MySQL Fully Qualified Domain Name"
  value       = module.database.mysql_fqdn
  sensitive   = true
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.main.name
}

output "mysql_username" {
  value     = module.database.mysql_username
  sensitive = true
}

output "mysql_password" {
  value     = module.database.mysql_password
  sensitive = true
}

output "mysql_database" {
  value = module.database.mysql_database
}

output "mysql_connection_string" {
  description = "MySQL connection string for the Bookstore database"
  value       = "mysql://${var.db_admin_username}:${var.db_admin_password}@${module.database.mysql_fqdn}:3306/bookstore"
  sensitive   = true
}
