output "resource_group_name" {
  value = azurerm_resource_group.student_registration.name
}

output "devops_public_ip" {
  value = azurerm_public_ip.devops.ip_address
}

output "devops_private_ip" {
  value = azurerm_network_interface.devops.private_ip_address
}

output "k8s_public_ip" {
  value = azurerm_public_ip.k8s.ip_address
}

output "k8s_private_ip" {
  value = azurerm_network_interface.k8s.private_ip_address
}
