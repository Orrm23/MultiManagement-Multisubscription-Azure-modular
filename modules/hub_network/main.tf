variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "hub_vnet_cidr" { type = list(string) }
variable "firewall_subnet_cidr" { type = string }
variable "gateway_subnet_cidr" { type = string }
variable "bastion_subnet_cidr" { type = string }

resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-connectivity-001"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.hub_vnet_cidr
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-afw-hub-001"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub_fw" {
  name                = "afw-hub-connectivity-001"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"

  ip_configuration {
    name                 = "fw-ipconfig"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

output "hub_vnet_id" { value = azurerm_virtual_network.hub.id }
output "hub_vnet_name" { value = azurerm_virtual_network.hub.name }
output "hub_resource_group_name" { value = azurerm_resource_group.hub.name }
output "firewall_private_ip" { value = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address }
