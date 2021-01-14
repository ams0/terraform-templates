output "jumpbox_ip" {
  description = "Jumpbox VM IP"
  value       = azurerm_linux_virtual_machine.jumpbox.public_ip_address
}

output "jumpbox_username" {
  description = "Jumpbox VM username"
  value       = var.vm_user
}

output "ssh_private_key" {
  value = tls_private_key.sshkey.private_key_pem
}
