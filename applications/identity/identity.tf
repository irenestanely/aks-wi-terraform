resource "azurerm_user_assigned_identity" "this" {
  name                = "uaid-${var.app_name}"
  resource_group_name = var.resource_group
  location            = var.location
}