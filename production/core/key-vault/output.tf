output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.ug_kiosk_key_vault.id
}
