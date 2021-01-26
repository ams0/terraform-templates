resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = var.name

  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_B4ms"
    vnet_subnet_id = var.vnet_subnet_id
  }

  role_based_access_control {
    enabled = true
  }
  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzUc+bnA4b1b9LE+nau4QFbEE+HFkO9FPVGGicnYzUUKqWD5aV7R5LCGb0gLJwBxcETxRM+6lZuCtaNuqGVT2A/yjOOq5VKblrfOx7nSulrovXsAbmtiwpslGWuetVWg85tcGIQkv0dOZW8eqzcwxeYsXZCKIWvXqMnPpBObmt+RyllF7Bu8C2qgV1UILnz37mPUVuIy+LjgVkreGxy4FywZVO3GdQvIU9oOX4EhZ8Xcf9COwa64lI1kwqMhO3kAimpBiczo7XRcF1jVwjni7WZQhTJe3LDgoDx2ELggF2DT9LVfzAjaIwtzRGvB68BUXpNK9licgOUTQWdILrNguj fake ssh key"
    }
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy = "calico"
  }
}

# Grant AKS cluster access to use AKS subnet

resource "azurerm_role_assignment" "aks" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = var.vnet_subnet_id # Subnet ID
}

