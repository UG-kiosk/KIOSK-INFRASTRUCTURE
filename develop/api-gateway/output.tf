output "api_management_api_id" {
    description = "The ID of the API Management API"
    value       = azurerm_api_management_api.ug_kiosk_api_gw.id
}