module "shared_envs_dev" {
  source = "../../shared-envs/development"
}

locals {
  docker_image = "${module.shared_envs_dev.docker_username}/kiosk-auth-api-dev:${var.docker_image_tag}"
}

resource "azurerm_service_plan" "kiosk_auth_api" {
  name                = var.app_service_name
  resource_group_name = module.shared_envs_dev.resource_group_name
  location            = module.shared_envs_dev.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "kiosk_auth_api" {
  name                          = var.app_service_name
  resource_group_name           = azurerm_service_plan.kiosk_auth_api.resource_group_name
  location                      = azurerm_service_plan.kiosk_auth_api.location
  service_plan_id               = azurerm_service_plan.kiosk_auth_api.id
  public_network_access_enabled = false

  site_config {
    always_on              = false
    api_management_api_id  = data.terraform_remote_state.ug_kiosk_api_gw_state.outputs.api_management_api_id
    vnet_route_all_enabled = true

    application_stack {
      docker_image_name   = local.docker_image
      docker_registry_url = module.shared_envs_dev.docker_registry
    }
  }

  app_settings = {
    WEBSITES_PORT          = "3000"
    JWT_SECRET             = data.azurerm_key_vault_secret.kiosk_auth_api_jwt_secret_key.value
    ACCESS_TOKEN_LIFETIME  = var.access_token_lifetime
    REFRESH_TOKEN_LIFETIME = var.refresh_token_lifetime
    MONGODB_URI            = data.azurerm_key_vault_secret.kiosk_auth_api_db_secret_key.value
  }
}

resource "azurerm_private_endpoint" "kiosk_auth_api_private_endpoint" {
  name                = "${var.app_service_name}-private-endpoint"
  location            = azurerm_service_plan.kiosk_auth_api.location
  resource_group_name = azurerm_service_plan.kiosk_auth_api.resource_group_name
  subnet_id           = data.terraform_remote_state.kiosk_network_state.outputs.kiosk_private_endpoints_subnet_id

  private_service_connection {
    name                           = "${var.app_service_name}-private-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_web_app.kiosk_auth_api.id
    subresource_names              = ["sites"]
  }
}

resource "azurerm_private_dns_a_record" "kiosk_auth_api_private_dns_a_record" {
  name                = azurerm_linux_web_app.kiosk_auth_api.name
  zone_name           = data.terraform_remote_state.kiosk_private_dns_state.outputs.private_dns_zone_name
  resource_group_name = module.shared_envs_dev.resource_group_name
  ttl                 = 300
  records             = [azurerm_private_endpoint.kiosk_auth_api_private_endpoint.private_service_connection[0].private_ip_address]
}
