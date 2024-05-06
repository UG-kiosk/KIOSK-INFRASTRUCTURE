module "shared_envs_dev" {
  source = "../../shared-envs/development"
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
  name                  = "${var.gateway_name}-GATEWAY"
  resource_group_name   = module.shared_envs_dev.resource_group_name
  api_management_name   = azurerm_api_management.ug-kiosk-api.name
  display_name          = "UG Kiosk API" 
  revision              = "1"
  path                  = ""
  protocols             = ["https"]
  subscription_required = false

  import {
    content_format = "swagger-json"
    content_value = file("swagger.json")
  }
}

resource "azurerm_api_management_api_policy" "ug-kiosk-api-policy" {
  api_name            = azurerm_api_management_api.ug-kiosk-api-gw.name
  api_management_name = azurerm_api_management.ug-kiosk-api.name
  resource_group_name = module.shared_envs_dev.resource_group_name
  
  xml_content = file("api-policy.xml")
}