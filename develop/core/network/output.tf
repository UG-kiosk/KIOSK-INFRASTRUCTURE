output "kiosk_microservices_subnet_id" {
  value = azurerm_subnet.kiosk_microservices_subnet.id
}

output "kiosk_api_management_subnet_id" {
    value = azurerm_subnet.kiosk_api_management_subnet.id
}
