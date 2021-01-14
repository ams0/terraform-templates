resource "azurerm_public_ip" "jumpbox" {
  name                = "jumpbox-pip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Dynamic"
  domain_name_label   = var.domain_name_label
}

resource "azurerm_network_security_group" "vm_sg" {
  name                = "vm-sg"
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "vmNicConfiguration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }
}

resource "azurerm_network_interface_security_group_association" "sg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_sg.id
}

resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                          = "jumpboxvm"
  location                      = var.location
  resource_group_name           = var.resource_group
  network_interface_ids         = [azurerm_network_interface.vm_nic.id]
  size                          = "Standard_DS1_v2"
  computer_name                 = "jumpboxvm"
  admin_username                = var.vm_user

  os_disk {
    name                 = "jumpboxOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  admin_ssh_key {
    username   = var.vm_user
    public_key = tls_private_key.sshkey.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  provisioner "remote-exec" {
    connection {
      host        = self.public_ip_address
      type        = "ssh"
      user        = var.vm_user
      private_key = tls_private_key.sshkey.private_key_pem
    }

    inline = [
      "mkdir /home/${var.vm_user}/.kube/ ; sudo snap install --classic kubectl",
    ]
    
  }
    provisioner "file" {
    connection {
      host        = self.public_ip_address
      type        = "ssh"
      user        = var.vm_user
      private_key = tls_private_key.sshkey.private_key_pem
    }

    content     = var.kube_config_raw
    destination = "/home/${var.vm_user}/.kube/config"
  }
}



resource "azurerm_private_dns_zone_virtual_network_link" "hublink" {
  name                  = "hubnetdnsconfig"
  resource_group_name   = var.dns_zone_resource_group
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = var.vnet_id
}
