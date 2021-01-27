output "nameSuffix" {
  value = data.external.get-namesuffix.result.nameSuffix
}

output "agents_resource_group_name" {
  value = local.agents_resource_group_name
}


output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}