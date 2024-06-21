data "terraform_remote_state" "kiosk_storage_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = module.shared_envs_dev.resource_group_name
    storage_account_name = "tfstateprxuh"
    container_name       = "tfstate"
    key                  = "kiosk-storage/terraform.tfstate"
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

data "azurerm_key_vault_secret" "storage_primary_access_key_secret_key" {
  name         = var.storage_primary_access_key_secret_key
  key_vault_id = data.terraform_remote_state.ug_kiosk_key_vault_state.outputs.key_vault_id
}
