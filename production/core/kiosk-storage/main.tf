module "shared_envs_prod" {
  source = "../../../shared-envs/production"
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_storage_account" "kiosk_storage" {
  name                     = "${var.storage_name}${random_string.resource_code.result}"
  resource_group_name      = module.shared_envs_prod.resource_group_name
  location                 = module.shared_envs_prod.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
