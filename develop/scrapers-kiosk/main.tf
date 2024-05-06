module "shared_envs_dev" {
  source = "../../shared-envs/development"
}

data "terraform_remote_state" "ug_kiosk_api_gw_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = "ug-kiosk-dev"
    storage_account_name = "tfstateprxuh"
    container_name       = "tfstate"
    key                  = "kiosk-gateway/terraform.tfstate"
  }
}

locals {
  docker_image = "${module.shared_envs_dev.docker_username}/kiosk-scrapers-dev:${var.docker_image_tag}"
}

resource "azurerm_service_plan" "scrapers-kiosk" {
  name                = var.app_service_name
  resource_group_name = module.shared_envs_dev.resource_group_name
  location            = module.shared_envs_dev.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "scrapers-kiosk" {
  name                = var.app_service_name
  resource_group_name = azurerm_service_plan.scrapers-kiosk.resource_group_name
  location            = azurerm_service_plan.scrapers-kiosk.location
  service_plan_id     = azurerm_service_plan.scrapers-kiosk.id
  
  site_config {
    always_on = false
    api_management_api_id = data.terraform_remote_state.ug_kiosk_api_gw_state.outputs.api_management_api_id

    application_stack {
      docker_image_name   = local.docker_image
      docker_registry_url = module.shared_envs_dev.docker_registry
    }
  }

  app_settings = {
    WEBSITES_PORT = "3000"
  }
}
