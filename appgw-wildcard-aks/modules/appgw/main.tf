resource "azurerm_public_ip" "appgwip" {
  name                = "appgwip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  domain_name_label   = var.appgw_pubip_label
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "aksappgw" {
  name                = "aksappgw"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  frontend_ip_configuration {
    name                 = "aksappgw-fip"
    public_ip_address_id = azurerm_public_ip.appgwip.id
  }

  frontend_port {
    name = "aksappgw-feport"
    port = 80
  }
  gateway_ip_configuration {
    name      = "aksappgw-subnet"
    subnet_id = var.gateway_ip_configuration_id
  }

  backend_address_pool {
    name  = "aksappgw-be"
    fqdns = [var.fqdn1, var.fqdn2]
  }

  backend_http_settings {
    name                                = "aksappgw-behhtp"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    #this seems to be erratic, try to change it if you get bad gateway hitting the frontend IP, but the backend is known to work.
    pick_host_name_from_backend_address = true
    request_timeout                     = 60
  }

  http_listener {
    name                           = "aksappgw-listen"
    frontend_ip_configuration_name = "aksappgw-fip"
    frontend_port_name             = "aksappgw-feport"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "aksappgw-routing"
    rule_type                  = "Basic"
    http_listener_name         = "aksappgw-listen"
    backend_address_pool_name  = "aksappgw-be"
    backend_http_settings_name = "aksappgw-behhtp"
  }
}