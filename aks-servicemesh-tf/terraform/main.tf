resource "azurerm_resource_group" "sm" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "sm" {
  name                = "sm"
  location            = azurerm_resource_group.sm.location
  resource_group_name = azurerm_resource_group.sm.name
  address_space       = var.vnet_address_prefix

}

resource "azurerm_subnet" "sm" {
  name                 = "sm"
  resource_group_name  = azurerm_resource_group.sm.name
  virtual_network_name = azurerm_virtual_network.sm.name
  address_prefixes     = var.subnet_address_prefix
}

module "aks" {
  source                         = "Azure/aks/azurerm"
  resource_group_name            = var.resource_group_name
  kubernetes_version             = var.kubernetes_version
  orchestrator_version           = "1.19.3"
  prefix                         = "sm"
  network_plugin                 = "kubenet"
  public_ssh_key                 = var.public_ssh_key
  vnet_subnet_id                 = azurerm_subnet.sm.id
  enable_log_analytics_workspace = false


  agents_count = var.agents_count

  network_policy = "calico"

  depends_on = [azurerm_subnet.sm]

}

#Terraform doesn't support variable interpolation here: https://github.com/hashicorp/terraform/issues/1439
#ToDO: use the notation: git::https://example.com/network.git//modules/vpc once this is pushed
module "service_mesh" {
  source            = "./modules/service_mesh"
  service_mesh_type = var.service_mesh_type
  kube_config_raw   = module.aks.kube_config_raw
}