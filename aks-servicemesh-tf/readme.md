# Multi-service mesh Terraform module for Azure Kubernetes Service

This terraform module will deploy an AKS cluster with your Service Mesh of choice, simply by setting the variable `service_mesh_type`. Possible values: `linkerd`, `osm` and `istio`, with a plan to support more meshes in the future.

To interact with the cluster after deployment, enter the `terraform` directory:

```bash
export KUBECONFIG=modules/service_mesh/.kube/config 
```

Istio:

```console
NAMESPACE      NAME                                                  READY   STATUS             RESTARTS   AGE
istio-system   istiod-6f5754c8b4-wwq2z                               1/1     Running            0          6m10s
```

OSM:

```console
NAMESPACE      NAME                                                  READY   STATUS             RESTARTS   AGE
osm           osm-controller-5d87ff7d6b-9zhmd                       1/1     Running            0          7h7m
```

Linkerd

```console
NAMESPACE     NAME                                                  READY   STATUS    RESTARTS   AGE
linkerd       linkerd-controller-568f77749b-v798s                   2/2     Running   0          110s
linkerd       linkerd-destination-7457489f8-xrtkv                   2/2     Running   0          110s
linkerd       linkerd-grafana-55dbf59ddb-892sr                      2/2     Running   0          110s
linkerd       linkerd-identity-54548557cc-g5ptt                     2/2     Running   0          110s
linkerd       linkerd-prometheus-54b6f78ffd-pb89j                   2/2     Running   0          110s
linkerd       linkerd-proxy-injector-b58f68f84-97d4d                2/2     Running   0          110s
linkerd       linkerd-sp-validator-57b859447-xsrrt                  2/2     Running   0          110s
linkerd       linkerd-tap-79fb4556cc-vk6pb                          2/2     Running   0          110s
linkerd       linkerd-web-59b9b7857-2l228                           2/2     Running   0          110s
```