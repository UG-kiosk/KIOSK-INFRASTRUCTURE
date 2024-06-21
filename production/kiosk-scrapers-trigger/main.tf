module "shared_envs_prod" {
  source = "../../shared-envs/production"
}

resource "azurerm_service_plan" "kiosk_scrapers_trigger_func" {
  name                = var.function_name
  resource_group_name = module.shared_envs_prod.resource_group_name
  location            = module.shared_envs_prod.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_function_app" "kiosk_scrapers_trigger_func" {
  name                = var.function_name
  resource_group_name = module.shared_envs_prod.resource_group_name
  location            = module.shared_envs_prod.location

  storage_account_name       = data.terraform_remote_state.kiosk_storage_state.outputs.kiosk_storage_name
  storage_account_access_key = data.azurerm_key_vault_secret.storage_primary_access_key_secret_key.value
  service_plan_id            = azurerm_service_plan.kiosk_scrapers_trigger_func.id

  app_settings = {
    GATEWAY_URL = module.shared_envs_prod.api_gateway_url
  }

  site_config {
    always_on = true

    application_stack {
      docker {
        image_name   = var.docker_image_name
        image_tag    = var.docker_image_tag
        registry_url = module.shared_envs_prod.docker_registry
      }
    }
  }
}
