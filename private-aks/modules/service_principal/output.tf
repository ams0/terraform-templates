output id {
  description = "Service Principal ID"
  value       = azuread_service_principal.aks_sp.id
}

output secret {
  description = "Service Principal password"
  value       = random_string.aks_cluster_password.result
}
