provider "azurerm" {
  features {
  }
  subscription_id                 = "f467eb35-c158-4c1c-82d2-d228854853b5"
  environment                     = "public"
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
  resource_provider_registrations = "none"
}
