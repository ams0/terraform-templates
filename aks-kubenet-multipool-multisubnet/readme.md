Creates an AKS cluster with Kubenet, a custom vnet and N subnets for N nodepools, associates those pools with the Route Table created by AKS (https://github.com/Azure/AKS/issues/1338).

terraform.tfvars

```
kubernetes_version = "1.18.14"
location           = "westeurope"
address_space      = ["172.20.0.0/16"]

defaultpool = [
  {
    name      = "base",
    vmsize    = "Standard_B4ms",
    nodecount = 2,
    cidr      = "172.20.1.0/24"
  },
]

pools = [
  {
    name      = "gpu",
    vmsize    = "Standard_B2ms",
    nodecount = 1,
    cidr      = "172.20.2.0/24"
  },

  {
    name      = "spot",
    vmsize    = "Standard_B4ms",
    nodecount = 1,
    cidr      = "172.20.3.0/24"
  },
]
```


based on 

https://stackoverflow.com/questions/56904745/terraform-optional-nested-object-variable
https://www.danielstechblog.io/terraform-working-with-aks-multiple-node-pools-in-tf-azure-provider-version-1-37/?_lrsc=b3e8b8e3-029d-4f5e-8d1e-260963c19e65
