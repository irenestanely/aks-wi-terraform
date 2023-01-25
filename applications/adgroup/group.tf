resource "azuread_group" "this" {
  display_name     = "adgroup-${var.app_name}"
  mail_enabled     = true
  mail_nickname    = "adgroup-${var.app_name}"
  security_enabled = true
  types            = ["Unified"]
}

