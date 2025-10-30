output "vm_public_ip" {
  description = "Public IP of the EpicBook VM"
  value       = azurerm_public_ip.vm.ip_address
}

output "vm_admin_user" {
  description = "Admin username"
  value       = "epicbookadmin"
}

