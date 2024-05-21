module "shared_envs_dev" {
  source = "../../../shared-envs/development"
}

resource "random_string" "resource_code" {
  length  = 6
  special = false
  upper   = false
}

locals {
  key_vault_full_name = "${var.key_vault_name}-${random_string.resource_code.result}"
}

resource "azurerm_key_vault" "ug_kiosk_key_vault" {
  name                        = local.key_vault_full_name
  location                    = module.shared_envs_dev.location
  resource_group_name         = module.shared_envs_dev.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  network_acls {
    bypass = "AzureServices"
    default_action = "Allow"
    virtual_network_subnet_ids = [data.terraform_remote_state.kiosk_network_state.outputs.kiosk_private_endpoints_subnet_id]
  }
}


resource "azurerm_key_vault_access_policy" "ug_kiosk_key_vault_access_policy" {
  key_vault_id = azurerm_key_vault.ug_kiosk_key_vault.id
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
