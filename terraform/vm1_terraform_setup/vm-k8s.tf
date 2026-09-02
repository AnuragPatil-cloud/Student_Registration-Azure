resource "azurerm_network_interface" "k8s" {
  name                = "Student-Registration-K8s-NIC"
  location            = azurerm_resource_group.student_registration.location
  resource_group_name = azurerm_resource_group.student_registration.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.student_registration.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.k8s.id
  }
}

resource "azurerm_network_interface_security_group_association" "k8s" {
  network_interface_id      = azurerm_network_interface.k8s.id
  network_security_group_id = azurerm_network_security_group.k8s.id
}

resource "azurerm_linux_virtual_machine" "k8s" {
  name                = "Student-Registration-K8s-VM"
  computer_name       = "student-k8s"
  location            = azurerm_resource_group.student_registration.location
  resource_group_name = azurerm_resource_group.student_registration.name
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.k8s.id
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
    role = "kubernetes"
  }
}
