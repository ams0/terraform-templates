resource "null_resource" "save-kube-config" {
  triggers = {
    config = var.kube_config_raw
  }

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/.kube
      echo "${var.kube_config_raw}" > ${path.module}/.kube/config
      chmod 0600 ${path.module}/.kube/config
EOF
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -R ${path.module}/.kube"
  }

}

module "istio" {
  count = var.service_mesh_type == "istio" ? "1" : "0"

  source          = "./modules/istio"
  kube_config_raw = var.kube_config_raw

  depends_on = [null_resource.save-kube-config]

}

module "linkerd" {
  count = var.service_mesh_type == "linkerd" ? "1" : "0"

  source          = "./modules/linkerd"
  kube_config_raw = var.kube_config_raw

  depends_on = [null_resource.save-kube-config]

}

module "osm" {
  count = var.service_mesh_type == "osm" ? "1" : "0"

  source          = "./modules/osm"
  kube_config_raw = var.kube_config_raw

  depends_on = [null_resource.save-kube-config]

}