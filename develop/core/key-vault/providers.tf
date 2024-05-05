terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "=3.89.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "ug-kiosk-dev"
    storage_account_name = "tfstateprxuh"
    container_name       = "tfstate"
    key                  = "kiosk-key-vault/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}