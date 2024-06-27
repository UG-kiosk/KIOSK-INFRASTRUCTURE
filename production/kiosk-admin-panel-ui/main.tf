module "shared_envs_prod" {
  source = "../../shared-envs/production"
}

locals {
  docker_image = "${module.shared_envs_prod.docker_username}/kiosk-admin-panel-ui-prod:${var.docker_image_tag}"
}

resource "azurerm_service_plan" "kiosk_admin_panel_ui" {
  name                = var.app_service_name
  resource_group_name = module.shared_envs_prod.resource_group_name
  location            = module.shared_envs_prod.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "kiosk_admin_panel_ui" {
  name                = var.app_service_name
  resource_group_name = azurerm_service_plan.kiosk_admin_panel_ui.resource_group_name
  location            = azurerm_service_plan.kiosk_admin_panel_ui.location
  service_plan_id     = azurerm_service_plan.kiosk_admin_panel_ui.id

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