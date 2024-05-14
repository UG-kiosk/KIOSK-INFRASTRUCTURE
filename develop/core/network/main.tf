module "shared_envs_dev" {
  source = "../../../shared-envs/development"
}

resource "azurerm_virtual_network" "kiosk_vnet" {
  name                = var.vnet_name
  resource_group_name = module.shared_envs_dev.resource_group_name
  location            = module.shared_envs_dev.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "kiosk_microservices_subnet" {
  name                 = var.microservices_subnet_name
  resource_group_name  = module.shared_envs_dev.resource_group_name
  virtual_network_name = azurerm_virtual_network.kiosk_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = var.microservices_delegation_name
    
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "microservices_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.kiosk_microservices_subnet.id
  network_security_group_id = azurerm_network_security_group.microservices_nsg.id
}

resource "azurerm_network_security_group" "api_management_nsg" {
  name                = var.api_management_nsg_name
  location            = module.shared_envs_dev.location
  resource_group_name = module.shared_envs_dev.resource_group_name

  security_rule {
    name                       = "AllowManagementEndpoint"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInternetAccess"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "kiosk_api_management_subnet" {
  name                 = var.api_management_subnet_name
  resource_group_name  = module.shared_envs_dev.resource_group_name
  virtual_network_name = azurerm_virtual_network.kiosk_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = ["Microsoft.Web"]
}

resource "azurerm_subnet_network_security_group_association" "apim_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.kiosk_api_management_subnet.id
  network_security_group_id = azurerm_network_security_group.api_management_nsg.id
}
