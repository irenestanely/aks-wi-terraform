output "principal_object_id" {
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "identity_id" {
  value       = azurerm_user_assigned_identity.this.id
}

output "client_id" {
  value       = azurerm_user_assigned_identity.this.client_id
}