#declared provider variables
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
  features {}
}

terraform {
    backend "azurerm" {}
}

resource "azurerm_resource_group" "lab" {
  name     = "adflabrg"
  location = "east us"
}

#Configure Virtual Network and subnets
resource "azurerm_virtual_network" "lab" {
  name                = "ADFvirtualNetwork1"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = ["10.0.0.0/16"]
 
}

resource "azurerm_subnet" "subnetA"{
    name    = "subnetA"
    resource_group_name         = azurerm_resource_group.lab.name
    virtual_network_name        = azurerm_virtual_network.lab.name
    address_prefixes            = ["10.0.1.0/24"]
    enforce_private_link_service_network_policies = false
    enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "subnetB"{
    name    = "subnetb"
    resource_group_name         = azurerm_resource_group.lab.name
    virtual_network_name        = azurerm_virtual_network.lab.name
    address_prefixes            = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "databrickspriv"{
    name    = "databrickspriv"
    resource_group_name         = azurerm_resource_group.lab.name
    virtual_network_name        = azurerm_virtual_network.lab.name
    address_prefixes            = ["10.0.3.0/24"]
    
    delegation {
    name = "dbprivdelegation"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "databrickspub"{
    name    = "databrickspub"
    resource_group_name         = azurerm_resource_group.lab.name
    virtual_network_name        = azurerm_virtual_network.lab.name
    address_prefixes            = ["10.0.4.0/24"]

    delegation {
    name = "dbpupdelegation"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

#configure NSG and associate it

resource "azurerm_network_security_group" "lab" {
  name                = "nsg1"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  security_rule {
    name                       = "allow443"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "assc1" {
  subnet_id                 = azurerm_subnet.databrickspub.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

resource "azurerm_subnet_network_security_group_association" "assc2" {
  subnet_id                 = azurerm_subnet.databrickspriv.id
  network_security_group_id = azurerm_network_security_group.lab.id
}

#configure Vnet Integrated Data Factory

resource "azurerm_data_factory" "lab" {
  name                = "bgcadflabadf"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
}

resource "azurerm_data_factory_integration_runtime_managed" "lab" {
  name                = "bgcadflabir"
  data_factory_name   = azurerm_data_factory.lab.name
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location

  node_size = "Standard_D8_v3"

  vnet_integration {
      vnet_id           = azurerm_virtual_network.lab.id
      subnet_name       = azurerm_subnet.subnetA.name
  }
}

#Configure Storage account

resource "azurerm_storage_account" "lab" {
  name                     = "bgcadflabsa"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "lab" {
  name               = "bgcadflabdl1"
  storage_account_id = azurerm_storage_account.lab.id

  properties = {
    hello = "aGVsbG8="
  }
}

#configure private endpoint for storage
resource "azurerm_private_endpoint" "datalakeep" {
  name                = "bgcadflabsape"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  subnet_id           = azurerm_subnet.subnetA.id

  private_service_connection {
    name                           = "bgcadflabpsc"
    private_connection_resource_id = azurerm_storage_account.lab.id
    subresource_names              = [ "dfs" ]
    is_manual_connection           = false
  }
}

#configure databricks workspace
resource "azurerm_databricks_workspace" "lab" {
  name                = "bgcadflabdatabricks1"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  sku                 = "standard"
  
  custom_parameters{
    virtual_network_id  = azurerm_virtual_network.lab.id
    public_subnet_name  = azurerm_subnet.databrickspub.name
    private_subnet_name = azurerm_subnet.databrickspriv.name
  }


    timeouts{
        create = "60m"
    }
}