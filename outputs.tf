output "storage_account_id" {
  description = "The ID of the Storage Account."
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "The name of the Storage Account."
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint of the Storage Account."
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "container_names" {
  description = "List of created container names."
  value       = [for c in azurerm_storage_container.containers : c.name]
}
