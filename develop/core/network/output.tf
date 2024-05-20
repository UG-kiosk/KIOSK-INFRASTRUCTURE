output "kiosk_api_management_subnet_id" {
    value = azurerm_subnet.kiosk_api_management_subnet.id
}

output "kiosk_private_endpoints_subnet_id" {
  value = azurerm_subnet.kiosk_private_endpoints_subnet.id
}
