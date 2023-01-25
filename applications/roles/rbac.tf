resource "azurerm_role_assignment" "group_resource_role" {
  principal_id         = var.ad_group_id //data.azuread_group.sg_az_sub-dev_reader_01.id
  scope                = var.scope
  role_definition_name = var.role_definition_name
}