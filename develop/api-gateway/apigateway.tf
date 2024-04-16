module "shared_envs_dev" {
  source = "../../shared-envs/development"
}

locals {
  api_config_file_path = "${path.module}/api-swagger.json"
}

resource "local_file" "api_spec_file" {
  filename = local.api_config_file_path
  content = templatefile("${path.module}/swagger.json", {
    translations_kiosk_api_url: "translations-kiosk-dev.azurewebsites.net"
    scrapers_kiosk_api_url: "scrapers-kiosk-dev.azurewebsites.net"
  })
}

resource "azurerm_api_management" "ug-kiosk-api" {
  name                = var.gateway_name
  location            = module.shared_envs_dev.location
  resource_group_name = module.shared_envs_dev.resource_group_name
  publisher_name      = "UG Kiosk"
  publisher_email     = "j.zapiorkowski.662@studms.ug.edu.pl"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_api" "ug-kiosk-api-gw" {
  name                = "${var.gateway_name}-GATEWAY"
  resource_group_name = module.shared_envs_dev.resource_group_name
  api_management_name = azurerm_api_management.ug-kiosk-api.name
  display_name        = "UG Kiosk API" 
  revision            = "1"
  path                = "api"
  protocols           = ["https"]

  import {
    content_format = "swagger-json"
    content_value = local_file.api_spec_file.content
  }

  depends_on = [azurerm_api_management.ug-kiosk-api]
}