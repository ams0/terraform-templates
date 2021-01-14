resource "azuread_application" "aks_sp" {
  name = "aks_sp"
}

resource "azuread_service_principal" "aks_sp" {
  application_id = azuread_application.aks_sp.id
}

resource "random_string" "aks_cluster_password" {
  length = 16
  special = false

  keepers = {
    service_principal = azuread_service_principal.aks_sp.id
  }
}

resource "azuread_service_principal_password" "server" {
  service_principal_id = azuread_service_principal.aks_sp.id
  value                = random_string.aks_cluster_password.result
  end_date             = timeadd(timestamp(), "87600h") # 10 years

  # The end date will change at each run (terraform apply), causing a new password to 
  # be set. So we ignore changes on this field in the resource lifecyle to avoid this
  # behaviour.
  # If the desired behaviour is to change the end date, then the resource must be
  # manually tainted.
  lifecycle {
    ignore_changes = [end_date]
  }
}
