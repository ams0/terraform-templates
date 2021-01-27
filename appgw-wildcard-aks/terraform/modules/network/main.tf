resource "azurerm_virtual_network" "appgw_vnet" {
  name                = "appgw_vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.appgw_vnet_address_space
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.appgw_vnet.name
  address_prefixes     = var.appgw_vnet_subnet_address_prefix
}

resource "azurerm_virtual_network" "c1_vnet" {
  name                = "c1_vnet"
  location            = var.location_c1
  resource_group_name = var.resource_group_name
  address_space       = var.c1_vnet_address_space
}

resource "azurerm_subnet" "c1_subnet" {
  name                 = "c1_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.c1_vnet.name
  address_prefixes     = var.c1_vnet_subnet_address_prefix
}

resource "azurerm_virtual_network" "c2_vnet" {
  name                = "c2_vnet"
  location            = var.location_c2
  resource_group_name = var.resource_group_name
  address_space       = var.c2_vnet_address_space
}

resource "azurerm_subnet" "c2_subnet" {
  name                 = "c2_subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.c2_vnet.name
  address_prefixes     = var.c2_vnet_subnet_address_prefix
}

resource "azurerm_virtual_network_peering" "appgwc1" {
  name                      = "appgwc1"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.appgw_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.c1_vnet.id
}

resource "azurerm_virtual_network_peering" "c1appgw" {
  name                      = "c1appgw"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.c1_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.appgw_vnet.id
}

resource "azurerm_virtual_network_peering" "appgwc2" {
  name                      = "appgwc2"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.appgw_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.c2_vnet.id
}

resource "azurerm_virtual_network_peering" "c2appgw" {
  name                      = "c2appgw"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.c2_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.appgw_vnet.id
}

