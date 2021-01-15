variable "location" {
  description = "The resource group location (use small cap, one word notation)"
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "The resource group name to be created"
  default     = "nopublicipaks"
}

variable "hub_vnet_name" {
  description = "Hub VNET name"
  default     = "hub1-firewalvnet"
}

variable "hub_address_space" {
  description = "Hub address space"
  default     = ["10.0.0.0/22"]
}

variable "hub_firewall_subnet" {
  description = "Hub VNET name"
  default     = ["10.0.0.0/24"]
}

variable "jumpbox_subnet" {
  description = "jumbox subnet prefix"
  default     = ["10.0.1.0/24"]
}

variable "kube_vnet_name" {
  description = "AKS VNET name"
  default     = "spoke1-kubevnet"
}

variable "kube_address_space" {
  description = "AKS VNET address space"
  default     =  ["10.0.16.0/20"]
}

variable "aks_subnet_prefix" {
  description = "AKS VNET address space for first pool"
  default     =  ["10.0.16.0/24"]
}

variable "kube_version" {
  description = "AKS Kubernetes version"
  default     = "1.18.8"
}


variable "nodepool_nodes_count" {
  description = "Default nodepool nodes count"
  default     = 1
}

variable "nodepool_vm_size" {
  description = "Default nodepool VM size"
  default     = "Standard_D2_v2"
}

variable "network_docker_bridge_cidr" {
  description = "CNI Docker bridge cidr"
  default     = "172.17.0.1/16"
}

variable "network_dns_service_ip" {
  description = "CNI DNS service IP"
  default     = "10.2.0.10"
}

variable "network_service_cidr" {
  description = "CNI service cidr"
  default     = "10.2.0.0/24"
}

variable "availability_zones" {
  description = "List of AZs for system (first) nodepool"
  default     = ["1"]
}

variable "domain_name_label" {
  description = "Domain name for jumbox"
  default     = "fullyprivaks"
}

variable "additional_node_pools" {
  type = list(object({
    name               = string
    vm_size            = string
    node_count         = number
    mode               = string
    availability_zones = list(string)
    os_type            = string
    priority           = string
    subnet_prefix      = list(string)
    tags               = map(string)
    node_labels        = map(string)
  }))
}