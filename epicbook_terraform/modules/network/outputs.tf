output "public_subnet_id" {
  value = azurerm_subnet.public.id
}

output "mysql_subnet_id" {
  value = azurerm_subnet.mysql.id
}

output "public_nsg_id" {
  value = azurerm_network_security_group.public.id
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.mysql.id
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}
