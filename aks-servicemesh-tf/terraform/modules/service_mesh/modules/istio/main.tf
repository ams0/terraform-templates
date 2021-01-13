resource "null_resource" "get-istio" {

  provisioner "local-exec" {
    command = "curl -Lso istio-${var.istio_archive_version}.tar.gz https://github.com/istio/istio/releases/download/${var.istio_archive_version}/istio-${var.istio_archive_version}-linux-amd64.tar.gz ; tar zxvf istio-${var.istio_archive_version}.tar.gz; rm istio-${var.istio_archive_version}.tar.gz "
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -R istio-*"
  }
}

resource "helm_release" "istio-base" {

  depends_on = [null_resource.get-istio]


  name             = "istio-base"
  chart            = "./istio-${var.istio_archive_version}/manifests/charts/base"
  namespace        = "istio-system"
  create_namespace = true
}

resource "helm_release" "istio-discovery" {

  depends_on = [null_resource.get-istio]

  name             = "istio-discovery"
  chart            = "./istio-${var.istio_archive_version}/manifests/charts/istio-control/istio-discovery"
  namespace        = "istio-system"
  create_namespace = true

  set {
    name  = "global.hub"
    value = "docker.io/istio"
  }

  set {
    name  = "global.tag"
    value = "1.8.1"
  }
}

#add if/count for this
resource "helm_release" "istio-ingress" {

  depends_on = [null_resource.get-istio]


  name             = "istio-ingress"
  chart            = "./istio-${var.istio_archive_version}/manifests/charts/gateways/istio-ingress"
  namespace        = "istio-system"
  create_namespace = true

  set {
    name  = "global.hub"
    value = "docker.io/istio"
  }

  set {
    name  = "global.tag"
    value = "1.8.1"
  }
}