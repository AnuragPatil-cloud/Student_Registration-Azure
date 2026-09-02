resource "azurerm_virtual_network" "student_registration" {
  name                = "Student-Registration-VNet"
  location            = azurerm_resource_group.student_registration.location
  resource_group_name = azurerm_resource_group.student_registration.name
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "student_registration" {
  name                 = "Student-Registration-Subnet"
  resource_group_name  = azurerm_resource_group.student_registration.name
  virtual_network_name = azurerm_virtual_network.student_registration.name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_public_ip" "devops" {
  name                = "Student-Registration-DevOps-PIP"
  location            = azurerm_resource_group.student_registration.location
  resource_group_name = azurerm_resource_group.student_registration.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "k8s" {
  name                = "Student-Registration-K8s-PIP"
  location            = azurerm_resource_group.student_registration.location
  resource_group_name = azurerm_resource_group.student_registration.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "devops" {
  name                = "Student-Registration-DevOps-NSG"
  location            = azurerm_resource_group.student_registration.location
  resource_group_name = azurerm_resource_group.student_registration.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Jenkins"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "k8s" {
  name                = "Student-Registration-K8s-NSG"
  location            = azurerm_resource_group.student_registration.location
  resource_group_name = azurerm_resource_group.student_registration.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Grafana"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
