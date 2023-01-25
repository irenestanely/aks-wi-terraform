resource "azurerm_storage_account" "app2" {
  name                     = "testsa${var.app_name}"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "app2"
  }
}

