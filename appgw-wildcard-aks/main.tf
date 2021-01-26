
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "network" {
  source                           = "./modules/network"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = var.location
  aksdnszone_name                  = var.aksdnszone_name
  location_c1                      = var.location_c1
  location_c2                      = var.location_c2
  appgw_vnet_address_space         = var.appgw_vnet_address_space
  appgw_vnet_subnet_address_prefix = var.appgw_vnet_subnet_address_prefix
  c1_vnet_address_space            = var.c1_vnet_address_space
  c1_vnet_subnet_address_prefix    = var.c1_vnet_subnet_address_prefix
  c2_vnet_address_space            = var.c2_vnet_address_space
  c2_vnet_subnet_address_prefix    = var.c2_vnet_subnet_address_prefix
}

module "appgw" {
  source                      = "./modules/appgw"
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = var.location
  appgw_pubip_label           = var.appgw_pubip_label
  gateway_ip_configuration_id = module.network.gateway_ip_configuration_id
  fqdn1                       = "ingress.${var.fqdn1}.${var.location_c1}.${module.network.aksdnszone}"
  fqdn2                       = "ingress.${var.fqdn2}.${var.location_c2}.${module.network.aksdnszone}"
}

module "aks_c1" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location_c1
  name                = var.fqdn1
  kubernetes_version  = var.kubernetes_version
  vnet_subnet_id      = module.network.c1_vnet_subnet_id
  aksdnszone          = module.network.aksdnszone
}

module "aks_c2" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location_c2
  name                = var.fqdn2
  kubernetes_version  = var.kubernetes_version
  vnet_subnet_id      = module.network.c2_vnet_subnet_id
  aksdnszone          = module.network.aksdnszone
}
