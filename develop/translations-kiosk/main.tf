module "shared_envs_dev" {
  source = "../../shared-envs/development"
}

locals {
  docker_image = "${module.shared_envs_dev.docker_username}/kiosk-translations-dev:${var.docker_image_tag}"
}

data "terraform_remote_state" "ug_kiosk_api_gw_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = module.shared_envs_dev.resource_group_name
    storage_account_name = "tfstateprxuh"
    container_name       = "tfstate"
    key                  = "kiosk-gateway/terraform.tfstate"
  }
}

data "terraform_remote_state" "ug_kiosk_key_vault_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = module.shared_envs_dev.resource_group_name
    storage_account_name = "tfstateprxuh"
    container_name       = "tfstate"
    key                  = "kiosk-key-vault/terraform.tfstate"
  }
}

data "azurerm_key_vault_secret" "translations_api_secret_key" {
  name         = var.translations_api_secret_key
  key_vault_id = data.terraform_remote_state.ug_kiosk_key_vault_state.outputs.key_vault_id
}

resource "azurerm_service_plan" "kiosk_translations" {
    name                = var.app_service_name
    resource_group_name = module.shared_envs_dev.resource_group_name
    location            = module.shared_envs_dev.location
    os_type             = "Linux"
    sku_name            = "B1"
}

resource "azurerm_linux_web_app" "kiosk_translations" {
    name                = var.app_service_name
    resource_group_name = azurerm_service_plan.kiosk_translations.resource_group_name
    location            = azurerm_service_plan.kiosk_translations.location
    service_plan_id     = azurerm_service_plan.kiosk_translations.id

    site_config {
        always_on = false
        api_management_api_id = data.terraform_remote_state.ug_kiosk_api_gw_state.outputs.api_management_api_id

        application_stack {
          docker_image_name   = local.docker_image
          docker_registry_url = module.shared_envs_dev.docker_registry
      }
    }

    app_settings = {
      TEXT_TRANSLATOR_API_REGION = var.translation_api_region
      TEXT_TRANSLATOR_API_KEY    = data.azurerm_key_vault_secret.translations_api_secret_key.value
      WEBSITES_PORT              = "8080"
    }
}