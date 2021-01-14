output "ssh_command" {
  value = "ssh -i ~/key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${module.jumpbox.jumpbox_username}@${var.domain_name_label}.${var.location}.cloudapp.azure.com kubectl cluster-info"
}

resource "local_file" "key" {
  filename = pathexpand("~/key")
  sensitive_content  = module.jumpbox.ssh_private_key
  file_permission = "0600"
}