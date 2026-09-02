resource "azurerm_network_interface" "devops" {
  name                = "Student-Registration-DevOps-NIC"
  location            = azurerm_resource_group.student_registration.location
  resource_group_name = azurerm_resource_group.student_registration.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.student_registration.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.devops.id
  }
}

resource "azurerm_network_interface_security_group_association" "devops" {
  network_interface_id      = azurerm_network_interface.devops.id
  network_security_group_id = azurerm_network_security_group.devops.id
}

resource "azurerm_linux_virtual_machine" "devops" {
  name                = "Student-Registration-DevOps-VM"
  computer_name       = "student-devops"
  location            = azurerm_resource_group.student_registration.location
  resource_group_name = azurerm_resource_group.student_registration.name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.devops.id
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = {
    role = "devops"
  }
}
