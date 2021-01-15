resource "null_resource" "get-osm" {

  provisioner "local-exec" {
    command = "git clone https://github.com/openservicemesh/osm.git 2>/dev/null | true"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -R osm"
  }
}

resource "helm_release" "osm" {

  depends_on = [null_resource.get-osm]


  name             = "osm"
  chart            = "./osm/charts/osm"
  namespace        = "osm"
  create_namespace = true



}