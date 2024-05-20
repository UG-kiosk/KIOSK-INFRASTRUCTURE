data "terraform_remote_state" "ug_kiosk_api_gw_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = "ug-kiosk-dev"
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

data "terraform_remote_state" "kiosk_private_dns_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = module.shared_envs_dev.resource_group_name
    storage_account_name = "tfstateprxuh"
    container_name       = "tfstate"
    key                  = "kiosk-dns-zone/terraform.tfstate"
  }
}

