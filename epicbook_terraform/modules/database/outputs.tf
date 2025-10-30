# modules/database/outputs.tf

output "mysql_fqdn" {
  description = "FQDN of the MySQL Flexible Server"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "mysql_username" {
  description = "Admin username for MySQL"
  value       = azurerm_mysql_flexible_server.main.administrator_login
}

output "mysql_password" {
  description = "Admin password for MySQL"
  value       = azurerm_mysql_flexible_server.main.administrator_password
  sensitive   = true
}

output "mysql_database" {
  description = "Database name"
  value       = azurerm_mysql_flexible_database.bookstore.name
}
