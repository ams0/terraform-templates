variable "resource_group_name" {
  default = "aksrg"
}


variable "kubernetes_version" {
}

variable "location" {
}

variable "address_space" {
}

variable "defaultpool" {
  type = list(object({
    cidr      = string,
    vmsize    = string,
    nodecount = string,
    name      = string
  }))
}

variable "pools" {
  type = list(object({
    cidr      = string,
    vmsize    = string,
    nodecount = string,
    name      = string
  }))
}
