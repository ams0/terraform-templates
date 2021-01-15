terraform {
  required_version = ">= 0.13"
}

provider "azurerm" {
  version = "~>2.5" //outbound_type https://github.com/terraform-providers/terraform-provider-azurerm/blob/v2.5.0/CHANGELOG.md
  features {}
}

resource "random_id" "rg" {
  byte_length = 8
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${lower(random_id.rg.hex)}"
  location = var.location
}


module "hub_network" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.hub_vnet_name
  address_space       = var.hub_address_space
  subnets = [
    {
      name : "AzureFirewallSubnet"
      address_prefixes : var.hub_firewall_subnet
    },
    {
      name : "jumpbox-subnet"
      address_prefixes : var.jumpbox_subnet
    }
  ]
}

module "kube_network" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = var.kube_vnet_name
  address_space       = var.kube_address_space
  subnets = [
    {
      name : "aks-subnet"
      address_prefixes : var.aks_subnet_prefix
    }
  ]
}

module "vnet_peering" {
  source              = "./modules/vnet_peering"
  vnet_1_name         = var.hub_vnet_name
  vnet_1_id           = module.hub_network.vnet_id
  vnet_1_rg           = azurerm_resource_group.rg.name
  vnet_2_name         = var.kube_vnet_name
  vnet_2_id           = module.kube_network.vnet_id
  vnet_2_rg           = azurerm_resource_group.rg.name
  peering_name_1_to_2 = "HubToSpoke1"
  peering_name_2_to_1 = "Spoke1ToHub"
}

module "firewall" {
  source         = "./modules/firewall"
  resource_group = azurerm_resource_group.rg.name
  location       = var.location
  pip_name       = "azureFirewalls-ip"
  fw_name        = "kubenetfw"
  subnet_id      = module.hub_network.subnet_ids["AzureFirewallSubnet"]
}

module "routetable" {
  source             = "./modules/route_table"
  resource_group     = azurerm_resource_group.rg.name
  location           = var.location
  rt_name            = "kubenetfw_fw_rt"
  r_name             = "kubenetfw_fw_r"
  firewal_private_ip = module.firewall.fw_private_ip
  subnet_id          = module.kube_network.subnet_ids["aks-subnet"]
}

resource "azurerm_kubernetes_cluster" "privateaks" {
  name                    = "private-aks"
  location                = var.location
  kubernetes_version      = var.kube_version
  resource_group_name     = azurerm_resource_group.rg.name
  dns_prefix              = "private-aks"
  private_cluster_enabled = true

  default_node_pool {
    name           = "default"
    node_count     = var.nodepool_nodes_count
    vm_size        = var.nodepool_vm_size
    vnet_subnet_id = module.kube_network.subnet_ids["aks-subnet"]
    availability_zones = var.availability_zones
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    docker_bridge_cidr = var.network_docker_bridge_cidr
    dns_service_ip     = var.network_dns_service_ip
    network_plugin     = "azure"
    outbound_type      = "userDefinedRouting"
    service_cidr       = var.network_service_cidr
  }

  depends_on = [module.routetable]
}

resource "azurerm_role_assignment" "netcontributor" {
  role_definition_name = "Network Contributor"
  scope                = module.kube_network.subnet_ids["aks-subnet"]
  principal_id         = azurerm_kubernetes_cluster.privateaks.identity[0].principal_id
}

module "jumpbox" {
  source                  = "./modules/jumpbox"
  location                = var.location
  domain_name_label       = var.domain_name_label
  resource_group          = azurerm_resource_group.rg.name
  vnet_id                 = module.hub_network.vnet_id
  kube_config_raw         = azurerm_kubernetes_cluster.privateaks.kube_config_raw
  subnet_id               = module.hub_network.subnet_ids["jumpbox-subnet"]
  dns_zone_name           = join(".", slice(split(".", azurerm_kubernetes_cluster.privateaks.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.privateaks.private_fqdn))))
  dns_zone_resource_group = azurerm_kubernetes_cluster.privateaks.node_resource_group
}

module "nodepool" {
  source = "./modules/nodepool"
  vnet_name   = var.kube_vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.privateaks.id
  additional_node_pools = var.additional_node_pools

    depends_on = [azurerm_kubernetes_cluster.privateaks]

}
