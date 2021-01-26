variable "poolsubnets" {
  description = "Subnets and pools"
  type        = "map"
  default = {

    akssubnetbase  = ["172.20.1.0/24", "Standard_B4ms", 1]
    akssubnetextra = ["172.20.2.0/24", "Standard_B4ms", 1]
  }
}