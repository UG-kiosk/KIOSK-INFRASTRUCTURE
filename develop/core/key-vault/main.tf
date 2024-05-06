module "shared_envs_dev" {
  source = "../../../shared-envs/development"
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

locals {
  key_vault_full_name = "${var.key_vault_name}-${random_string.resource_code.result}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "ug-kiosk-key-vault" {
  name                        = local.key_vault_full_name
  location                    = module.shared_envs_dev.location
  resource_group_name         = module.shared_envs_dev.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
}


resource "azurerm_key_vault_access_policy" "ug-kiosk-key-vault-access-policy" {
  key_vault_id = azurerm_key_vault.ug-kiosk-key-vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "Create",
    "List"
  ]

  secret_permissions = [
    "Get",
    "Set",
    "List"
  ]
}
