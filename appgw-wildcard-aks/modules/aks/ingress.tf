# fix to 1.24 https://medium.com/@nitinnbisht/annotation-in-helm-with-terraform-3fa04eb30b6e

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)

}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)

  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
  depends_on = [azurerm_kubernetes_cluster.aks]

}

resource "helm_release" "nginx-ingress" {
  name      = "nginx-ingress"
  chart     = "stable/nginx-ingress"
  namespace = "ingress"

  #because of inconsisten behaviour on Network Contributor role propagation of the identity[0].principal_id on the subnet, helm will fail. We can increase the timeout or set wait=false
  timeout    = 1000
  depends_on = [kubernetes_namespace.ingress]

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
    type  = "string"
  }
}

data "kubernetes_service" "nginx-ingress-controller" {
  metadata {
    name      = "nginx-ingress-controller"
    namespace = "ingress"
  }
  depends_on = [helm_release.nginx-ingress]

}

resource "azurerm_private_dns_a_record" "ingress" {
  name                = "ingress.${var.name}.${var.location}"
  zone_name           = var.aksdnszone
  resource_group_name = var.resource_group_name
  ttl                 = 30
  records             = [data.kubernetes_service.nginx-ingress-controller.status.0.load_balancer.0.ingress.0.ip]
}

