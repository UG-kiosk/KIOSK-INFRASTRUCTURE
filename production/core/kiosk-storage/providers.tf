terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "=3.89.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "ug-kiosk-prod"
    storage_account_name = "tfstatefegx2"
    container_name       = "tfstate"
    key                  = "kiosk-storage/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}