resource "azuread_group_member" "this" {
  group_object_id  = var.group_id
  member_object_id = var.object_id
}