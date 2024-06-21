module "shared_envs_prod" {
  source = "../../../shared-envs/production"
}

resource "azurerm_virtual_network" "kiosk_vnet" {
  name                = var.vnet_name
  resource_group_name = module.shared_envs_prod.resource_group_name
  location            = module.shared_envs_prod.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_network_security_group" "api_management_nsg" {
  name                = var.api_management_nsg_name
  location            = module.shared_envs_prod.location
  resource_group_name = module.shared_envs_prod.resource_group_name

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

  security_rule {
    name                       = "AllowPrivateEndpointsToAPIM"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.kiosk_private_endpoints_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAPIMToPrivateEndpoints"
    priority                   = 1006
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_subnet.kiosk_private_endpoints_subnet.address_prefixes[0]
  }
}

resource "azurerm_subnet" "kiosk_api_management_subnet" {
  name                 = var.api_management_subnet_name
  resource_group_name  = module.shared_envs_prod.resource_group_name
  virtual_network_name = azurerm_virtual_network.kiosk_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = ["Microsoft.Web"]
}

resource "azurerm_subnet_network_security_group_association" "apim_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.kiosk_api_management_subnet.id
  network_security_group_id = azurerm_network_security_group.api_management_nsg.id
}

resource "azurerm_subnet" "kiosk_private_endpoints_subnet" {
  name                 = var.private_endpoints_subnet_name
  resource_group_name  = module.shared_envs_prod.resource_group_name
  virtual_network_name = azurerm_virtual_network.kiosk_vnet.name
  address_prefixes     = ["10.0.3.0/24"]

  service_endpoints = ["Microsoft.Web", "Microsoft.KeyVault"]
}

resource "azurerm_network_security_group" "private_endpoints_nsg" {
  name                = var.private_endpoints_nsg_name
  location            = module.shared_envs_prod.location
  resource_group_name = module.shared_envs_prod.resource_group_name

  security_rule {
    name                       = "AllowAPIMToPrivateEndpoints"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = azurerm_subnet.kiosk_api_management_subnet.address_prefixes[0]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPrivateEndpointsToAPIM"
    priority                   = 1002
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = azurerm_subnet.kiosk_api_management_subnet.address_prefixes[0]
  }
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.kiosk_private_endpoints_subnet.id
  network_security_group_id = azurerm_network_security_group.private_endpoints_nsg.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "kiosk_dns_zone" {
  name                  = var.dns_zone_name
  resource_group_name   = module.shared_envs_prod.resource_group_name
  private_dns_zone_name = data.terraform_remote_state.kiosk_private_dns_state.outputs.private_dns_zone_name
  virtual_network_id    = azurerm_virtual_network.kiosk_vnet.id
}
