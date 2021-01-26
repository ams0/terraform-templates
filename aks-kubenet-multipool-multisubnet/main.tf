provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aksrg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "aksvnet" {
  name                = "aksvnet"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  address_space       = var.address_space

}

resource "azurerm_subnet" "basesubnet" {
  name                 = var.defaultpool[0].name
  address_prefix       = var.defaultpool[0].cidr
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  resource_group_name  = azurerm_resource_group.aksrg.name

}


resource "azurerm_subnet" "poolsubnets" {
  count                = length(var.pools)
  name                 = var.pools[count.index].name
  address_prefix       = var.pools[count.index].cidr
  virtual_network_name = azurerm_virtual_network.aksvnet.name
  resource_group_name  = azurerm_resource_group.aksrg.name

}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  dns_prefix          = "aks"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name           = var.defaultpool[0].name
    node_count     = var.defaultpool[0].nodecount
    vm_size        = var.defaultpool[0].vmsize
    vnet_subnet_id = azurerm_subnet.basesubnet.id
  }

  addon_profile {
    kube_dashboard {
      enabled = false
    }
  }

  network_profile {
    network_plugin     = "kubenet"
    network_policy     = "calico"
    service_cidr       = "10.0.0.0/16"
    docker_bridge_cidr = "172.17.0.1/16"
    dns_service_ip     = "10.0.0.10"
    load_balancer_sku  = "Standard"
  }
  service_principal {
    client_id     = var.kubernetes_client_id
    client_secret = var.kubernetes_client_secret
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "extra" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id


  count          = length(var.pools)
  name           = var.pools[count.index].name
  vm_size        = var.pools[count.index].vmsize
  node_count     = var.pools[count.index].nodecount
  vnet_subnet_id = azurerm_subnet.poolsubnets[count.index].id

}

locals {
  agents_resource_group_name = "MC_${azurerm_resource_group.aksrg.name}_${azurerm_kubernetes_cluster.aks.name}_${azurerm_resource_group.aksrg.location}"
}

data "azurerm_resource_group" "agents" {
  name = "${local.agents_resource_group_name}"

  depends_on = [
    azurerm_kubernetes_cluster.aks,
  ]
}

data "external" "get-namesuffix" {
  program = ["/bin/sh", "${path.module}/get_nameSuffix.sh"]

  query = {
    rg_name  = azurerm_resource_group.aksrg.name
    aks_name = azurerm_kubernetes_cluster.aks.name
  }

}

data "azurerm_route_table" "aksrt" {
  name                = "aks-agentpool-${data.external.get-namesuffix.result.nameSuffix}-routetable"
  resource_group_name = "${local.agents_resource_group_name}"
}

resource "azurerm_subnet_route_table_association" "poolsubnets" {
  count = length(var.pools)

  subnet_id      = azurerm_subnet.poolsubnets[count.index].id
  route_table_id = data.azurerm_route_table.aksrt.id
}
