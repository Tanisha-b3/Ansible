output "public_ips" {
  description = "List of public IPs for VMs in index order (0..3)"
  value = [
    for p in azurerm_public_ip.pubip : p.ip_address
  ]
}

 output "vm_names" {
  value = [for v in azurerm_linux_virtual_machine.vm : v.name]
 }

 output "vm_roles" {
 value = [for v in azurerm_linux_virtual_machine.vm : v.tags.role]
 }
