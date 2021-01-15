locals {
  additional_node_pools = flatten([
    for np in var.additional_node_pools : {
      name               = np.name
      vm_size            = np.vm_size
      node_count         = np.node_count
      mode               = np.mode
      availability_zones = np.availability_zones
      os_type            = np.os_type
      priority           = np.priority
      subnet_prefix      = np.subnet_prefix

      tags        = np.tags
      node_labels = np.node_labels
    }
  ])
}

resource "azurerm_subnet" "subnet" {
  for_each = { for np in local.additional_node_pools : np.name => np }

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = each.value.subnet_prefix
}

resource "azurerm_kubernetes_cluster_node_pool" "additional_pools" {
  for_each = { for np in local.additional_node_pools : np.name => np }

  kubernetes_cluster_id = var.kubernetes_cluster_id
  name                  = each.key
  vm_size               = each.value.vm_size
  mode                  = each.value.mode
  availability_zones    = each.value.availability_zones
  os_type               = each.value.os_type
  priority              = each.value.priority

  node_count = each.value.node_count

  node_labels = each.value.node_labels
  tags        = each.value.tags
}
