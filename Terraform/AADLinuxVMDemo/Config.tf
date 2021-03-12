terraform {
  required_providers {
    azurerm = "~> 2.50"
  }
}

provider "azurerm" {
  subscription_id       = var.subscription_id
  client_id             = var.client_id
  client_secret         = var.client_secret
  tenant_id             = var.tenant_id
  features {}
}

resource "tls_private_key" "example" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "azurerm_resource_group" "example" {
  name     = var.RGname
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = "AADlinuxVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "Default"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/27"]
}

resource "azurerm_public_ip" "vmpip" {
  name = "AADLinux-pip"
  location = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method = "Dynamic"
  sku = "Basic"
}

resource "azurerm_network_interface" "example" {
  name                = "AADLinux-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vmpip.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "AADLinux-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
 # admin_password      = "adlfkjwADFe6"
  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

    admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.example.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "adextenstion" {
    name                       = "AADLoginForLinux"
    virtual_machine_id         = azurerm_linux_virtual_machine.example.id
    publisher                  = "Microsoft.Azure.ActiveDirectory.LinuxSSH"
    type                       = "AADLoginForLinux"
    type_handler_version       = "1.0"
    auto_upgrade_minor_version = true

}

resource "azurerm_network_security_group" "example" {
  name                = "InternalSubnetNSG"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "inboundAllow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

data "azurerm_public_ip" "example" {
  name                = azurerm_public_ip.vmpip.name
  resource_group_name = azurerm_linux_virtual_machine.example.resource_group_name
}

output "tls_private_key" {
    value = tls_private_key.example.private_key_pem
}
output "public_ip_address" {
    value = data.azurerm_public_ip.example.ip_address
}