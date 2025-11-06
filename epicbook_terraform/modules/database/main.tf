resource "azurerm_mysql_flexible_server" "main" {
  name                   = "bookstore"
  resource_group_name    = var.resource_group_name
  location               = var.location
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  sku_name               = var.db_sku_name
  version                = "8.0.21"

  storage {
    size_gb = 20
    iops    = 360
  }

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = var.tags
}

resource "azurerm_mysql_flexible_database" "bookstore" {
  name                = "bookstore"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}


resource "azurerm_mysql_flexible_server_firewall_rule" "allow_app" {
  name                = "allow-app-subnet"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = var.backend_ip 
  end_ip_address      = var.backend_ip
}
