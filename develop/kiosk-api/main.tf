module "shared_envs_dev" {
  source = "../../shared-envs/development"
}

locals {
  docker_image = "${module.shared_envs_dev.docker_username}/kiosk-api-dev:${var.docker_image_tag}"
}

resource "azurerm_service_plan" "kiosk_api" {
  name                = var.app_service_name
  resource_group_name = module.shared_envs_dev.resource_group_name
  location            = module.shared_envs_dev.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "kiosk_api" {
  name                = var.app_service_name
  resource_group_name = azurerm_service_plan.kiosk_api.resource_group_name
  location            = azurerm_service_plan.kiosk_api.location
  service_plan_id     = azurerm_service_plan.kiosk_api.id
  

  site_config {
    always_on = false
    api_management_api_id = data.terraform_remote_state.ug_kiosk_api_gw_state.outputs.api_management_api_id

    application_stack {
      docker_image_name   = local.docker_image
      docker_registry_url = module.shared_envs_dev.docker_registry
    }

    ip_restriction {
      name  = "allow-microservices"
      action = "Allow"
      virtual_network_subnet_id = data.terraform_remote_state.kiosk_network_state.outputs.kiosk_microservices_subnet_id
    }

    ip_restriction {
      name  = "allow-apim"
      action = "Allow"
      virtual_network_subnet_id = data.terraform_remote_state.kiosk_network_state.outputs.kiosk_api_management_subnet_id
    }
  }

  app_settings = {
    WEBSITES_PORT = "8080"
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "subnet_connection" {
  app_service_id = azurerm_linux_web_app.kiosk_api.id
  subnet_id      = data.terraform_remote_state.kiosk_network_state.outputs.kiosk_microservices_subnet_id
}
