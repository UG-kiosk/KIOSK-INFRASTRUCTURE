module "shared_envs_prod" {
  source = "../../../shared-envs/production"
}

resource "azurerm_private_dns_zone" "kiosk_private_dns_zone" {
  name                = var.private_dns_zone_name
  resource_group_name = module.shared_envs_prod.resource_group_name
}
