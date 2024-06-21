module "shared_envs_prod" {
  source = "../../shared-envs/production"
}

locals {
  docker_image = "${module.shared_envs_prod.docker_username}/kiosk-ui-develop:${var.docker_image_tag}"
}

resource "azurerm_service_plan" "ui_kiosk" {
  name                = var.app_service_name
  resource_group_name = module.shared_envs_prod.resource_group_name
  location            = module.shared_envs_prod.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "ui_kiosk" {
  name                = var.app_service_name
  resource_group_name = azurerm_service_plan.ui_kiosk.resource_group_name
  location            = azurerm_service_plan.ui_kiosk.location
  service_plan_id     = azurerm_service_plan.ui_kiosk.id

  site_config {
    always_on = false

    application_stack {
      docker_image_name   = local.docker_image
      docker_registry_url = module.shared_envs_prod.docker_registry
    }
  }
  
  app_settings = {
    WEBSITES_PORT = "80"
  }
}