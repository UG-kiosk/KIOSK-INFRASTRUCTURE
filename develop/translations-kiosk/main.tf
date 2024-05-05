module "shared_envs_dev" {
  source = "../../shared-envs/development"
}

locals {
  docker_image = "${module.shared_envs_dev.docker_username}/kiosk-translations-dev:${var.docker_image_tag}"
}

data "azurerm_key_vault" "ug-kiosk-vault" {
  name                = module.shared_envs_dev.key_vault_name
  resource_group_name = module.shared_envs_dev.resource_group_name
}

data "azurerm_key_vault_secret" "translations_api_secret_key" {
  name         = "TRANSLATIONS-API-KEY-SECRET"
  key_vault_id = data.azurerm_key_vault.ug-kiosk-vault.id
}

resource "azurerm_service_plan" "kiosk-translations" {
    name                = var.app_service_name
    resource_group_name = module.shared_envs_dev.resource_group_name
    location            = module.shared_envs_dev.location
    os_type             = "Linux"
    sku_name            = "B1"
}

resource "azurerm_linux_web_app" "kiosk-translations" {
    name                = var.app_service_name
    resource_group_name = azurerm_service_plan.kiosk-translations.resource_group_name
    location            = azurerm_service_plan.kiosk-translations.location
    service_plan_id     = azurerm_service_plan.kiosk-translations.id

    site_config {
        always_on = false

        application_stack {
          docker_image_name   = local.docker_image
          docker_registry_url = module.shared_envs_dev.docker_registry
      }
    }

    app_settings = {
      TEXT_TRANSLATOR_API_REGION = var.translation-api-region
      TEXT_TRANSLATOR_API_KEY    = data.azurerm_key_vault_secret.translations_api_secret_key.value
    }
}