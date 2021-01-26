variable "resource_group_name" {
  description = "resource_group_name"
  default     = ""
}

variable "location" {
  description = "location"
  default     = ""
}

variable "aksdnszone_name" {
  description = "aksdnszone_name"
  default     = ""
}


variable "location_c1" {
  description = "location_c1"
  default     = ""
}

variable "location_c2" {
  description = "location_c2"
  default     = ""
}
variable "appgw_vnet_address_space" {
  description = "appgw_vnet_address_space"
  default     = ""
}

variable "appgw_vnet_subnet_address_prefix" {
  description = "appgw_vnet_subnet_address_prefix"
  default     = ""
}

variable "c1_vnet_address_space" {
  description = "c1_vnet_address_space"
  default     = ""
}

variable "c1_vnet_subnet_address_prefix" {
  description = "c1_vnet_subnet_address_prefix"
  default     = ""
}

variable "c2_vnet_address_space" {
  description = "c2_vnet_address_space"
  default     = ""
}

variable "c2_vnet_subnet_address_prefix" {
  description = "c2_vnet_subnet_address_prefix"
  default     = ""
}