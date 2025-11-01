output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.main.id
}
output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.main.name
}
output "primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}
output "primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}
output "containers" {
  description = "Map of created storage containers"
  value       = azurerm_storage_container.containers
}