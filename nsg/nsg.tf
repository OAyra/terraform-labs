provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources2"
  location = "eastus2"
}

resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgassociation3" {
  subnet_id                 = "/subscriptions/f264f4fe-b8cc-4f3e-a5dd-c0b731ac2d7e/resourceGroups/RSGREU2APISD01/providers/Microsoft.Network/virtualNetworks/vneteu2apisd01/subnets/subnet01eu2apisd01"
  network_security_group_id = azurerm_network_security_group.example.id
}