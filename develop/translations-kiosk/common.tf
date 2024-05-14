data "terraform_remote_state" "ug_kiosk_api_gw_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = module.shared_envs_dev.resource_group_name
    storage_account_name = "tfstateprxuh"
    container_name       = "tfstate"
    key                  = "kiosk-gateway/terraform.tfstate"
  }
}

data "terraform_remote_state" "kiosk_network_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = module.shared_envs_dev.resource_group_name
    storage_account_name = "tfstateprxuh"
    container_name       = "tfstate"
    key                  = "kiosk-network/terraform.tfstate"
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
