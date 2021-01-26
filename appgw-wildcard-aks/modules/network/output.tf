output "gateway_ip_configuration_id" {
  value = azurerm_subnet.appgw_subnet.id
}

output "c1_vnet_subnet_id" {
  value = azurerm_subnet.c1_subnet.id
}


output "c2_vnet_subnet_id" {
  value = azurerm_subnet.c2_subnet.id
}

output "aksdnszone" {
  value = azurerm_private_dns_zone.aksdnszone.name
}