resource "azurerm_private_dns_zone" "aksdnszone" {
  name                = var.aksdnszone_name
  resource_group_name = var.resource_group_name
}


resource "azurerm_private_dns_zone_virtual_network_link" "appgwdnslink" {
  name                  = "appgwdnslink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.aksdnszone.name
  virtual_network_id    = azurerm_virtual_network.appgw_vnet.id
}

