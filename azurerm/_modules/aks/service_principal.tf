resource "azuread_application" "current" {
  count = var.disable_managed_identities == true ? 1 : 0

  display_name = var.metadata_name
}

resource "azuread_service_principal" "current" {
  count = var.disable_managed_identities == true ? 1 : 0

  application_id = azuread_application.current[0].application_id
}

resource "random_string" "password" {
  count = var.disable_managed_identities == true ? 1 : 0

  length  = 64
  special = true
}

resource "azuread_service_principal_password" "current" {
  count = var.disable_managed_identities == true ? 1 : 0

  service_principal_id = azuread_service_principal.current[0].id
  value                = random_string.password[0].result
  end_date_relative    = var.service_principal_end_date_relative
}
