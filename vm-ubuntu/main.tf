provider "azurerm" {
  features {}
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "pubIP-${var.prefix}"
  location            = "${var.location}"
  resource_group_name = "${var.resourcegroup}"
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${var.prefix}"
  resource_group_name = "${var.resourcegroup}"
  location            = "${var.location}"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${var.subnet_info.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "vm-${var.prefix}"
  resource_group_name             = "${var.resourcegroup}"
  location                        = "${var.location}"
  size                            = "Standard_B1s"
  admin_username                  = "${var.vm_info.username}"
  admin_password                  = "${var.vm_info.password}"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_network_security_group" "nsg_subnet" {
  name                = "nsg-${var.prefix}"
  location            = "${var.location}"
  resource_group_name = "${var.resourcegroup}"
}

resource "azurerm_network_security_rule" "rule1" {
      name                       = "expose-ssh"
      priority                   = 112
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      resource_group_name        = "${var.resourcegroup}"
      network_security_group_name= azurerm_network_security_group.nsg_subnet.name
}

resource "azurerm_network_security_rule" "rule2" {
      name                       = "expose-openapi"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3030"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      resource_group_name        = "${var.resourcegroup}"
      network_security_group_name= azurerm_network_security_group.nsg_subnet.name
}

resource "azurerm_subnet_network_security_group_association" "nsgassociation" {
  subnet_id                 = "${var.subnet_info.id}"
  network_security_group_id = azurerm_network_security_group.nsg_subnet.id
}