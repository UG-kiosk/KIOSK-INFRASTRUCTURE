module "shared_envs_dev" {
  source = "../../shared-envs/development"
}

resource "azurerm_api_management" "ug_kiosk_apim" {
  name                 = var.apim_name
  location             = module.shared_envs_dev.location
  resource_group_name  = module.shared_envs_dev.resource_group_name
  publisher_name       = "UG Kiosk"
  publisher_email      = "j.zapiorkowski.662@studms.ug.edu.pl"
  virtual_network_type = "External"
  
  sku_name             = "Developer_1"

  virtual_network_configuration {
    subnet_id = data.terraform_remote_state.kiosk_network_state.outputs.kiosk_api_management_subnet_id
  }
}

resource "azurerm_api_management_api" "ug_kiosk_apim_api" {
  name                  = "${var.apim_name}-api"
  resource_group_name   = module.shared_envs_dev.resource_group_name
  api_management_name   = azurerm_api_management.ug_kiosk_apim.name
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

resource "azurerm_api_management_api_policy" "ug_kiosk_api_policy" {
  api_name            = azurerm_api_management_api.ug_kiosk_apim_api.name
  api_management_name = azurerm_api_management.ug_kiosk_apim.name
  resource_group_name = module.shared_envs_dev.resource_group_name
  
  xml_content = file("api-policy.xml")
}
