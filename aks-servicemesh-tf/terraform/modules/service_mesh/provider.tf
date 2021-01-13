provider "helm" {
  kubernetes {
    config_path = "${path.module}/.kube/config"
  }
}
