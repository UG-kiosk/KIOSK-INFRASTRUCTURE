terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "=3.89.0"
    }

    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "1.16.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "ug-kiosk-prod"
    storage_account_name = "tfstatefegx2"
    container_name       = "tfstate"
    key                  = "mongodb-atlas/terraform.tfstate"
  }
}

data "terraform_remote_state" "ug_kiosk_key_vault_state" {
  backend = "azurerm"
  config = {
    resource_group_name  = module.shared_envs_dev.resource_group_name
    storage_account_name = "tfstatefegx2"
    container_name       = "tfstate"
    key                  = "kiosk-key-vault/terraform.tfstate"
  }
}

data "azurerm_key_vault_secret" "mongodbatlas_private_key" {
  name         = var.mongodbatlas_private_key_secret_name
  key_vault_id = data.terraform_remote_state.ug_kiosk_key_vault_state.outputs.key_vault_id
}

provider "azurerm" {
  features {}
}

provider "mongodbatlas" {
  public_key = var.mongodbatlas_public_key
  private_key  = data.azurerm_key_vault_secret.mongodbatlas_private_key.value
}
