resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    environment = "dev"
    source      = "Terraform"
    owner       = "Maksim"
  }
}


data "azuread_client_config" "current" {}


resource "azuread_application" "backend_prod" {
  display_name     = "backend-prod"
  sign_in_audience = "AzureADMyOrg"
  owners           = [data.azuread_client_config.current.object_id]
  identifier_uris = ["api://platform.data-dev.reagle.fi"]


  single_page_application {
    redirect_uris = [
      "https://platform.data-dev.reagle.fi/api/microsoft-oauth/callback/"
    ]
  }

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      id                         = var.oauth2_permission_scope_id
      value                      = "user_impersonation"
      type                       = "User"
      enabled                    = true
      admin_consent_display_name  = "Access backend API"
      admin_consent_description  = "Allows delegated access to backend API"
      user_consent_display_name   = "Access backend API"
      user_consent_description    = "Allows delegated access to backend API"
    }
  }
}


resource "azuread_application" "backend_dev" { # rename to local
  display_name     = "backend-dev"
  sign_in_audience = "AzureADMyOrg"
  owners           = [data.azuread_client_config.current.object_id]
  identifier_uris = ["api://localhost:9275"]

  single_page_application {
    redirect_uris = [
      "https://localhost:9275/api/microsoft-oauth/callback/",
      "https://localhost:8000/api/microsoft-oauth/callback/",
      "http://localhost:8000/api/microsoft-oauth/callback/",
    ]
  }

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      id                         = var.oauth2_permission_scope_id
      value                      = "user_impersonation"
      type                       = "User"
      enabled                    = true
      admin_consent_display_name  = "Access backend API"
      admin_consent_description  = "Allows delegated access to backend API"
      user_consent_display_name   = "Access backend API"
      user_consent_description    = "Allows delegated access to backend API"
    }
  }
}

# ------------------------
# Preauthorize the Excel add-in
# ------------------------
resource "azuread_application_pre_authorized" "office_apps_dev" {
  application_id       = azuread_application.backend_dev.id
  authorized_client_id = var.office_apps_client_id

  permission_ids = [
    var.oauth2_permission_scope_id
  ]
}


resource "azuread_application_pre_authorized" "office_apps_prod" {
  application_id       = azuread_application.backend_prod.id
  authorized_client_id = var.office_apps_client_id

  permission_ids = [
    var.oauth2_permission_scope_id
  ]
}
