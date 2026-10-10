variable "spoke_config" {
  type = object({
    environment     = string
    subscription_id = string
    vnet_cidr       = list(string)
    subnets = map(object({
      address_prefix   = string
      delegation       = optional(string)
    }))
  })
}
variable "location" { type = string }
variable "hub_vnet_id" { type = string }
variable "hub_vnet_name" { type = string }
variable "hub_rg_name" { type = string }
variable "firewall_private_ip" { type = string }

resource "azurerm_resource_group" "spoke" {
  name     = "rg-spoke-${var.spoke_config.environment}-001"
  location = var.location
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-${var.spoke_config.environment}-001"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = var.spoke_config.vnet_cidr
}

resource "azurerm_route_table" "udr" {
  name                = "rt-spoke-${var.spoke_config.environment}-001"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name

  route {
    name                   = "DefaultOutboundToHubFirewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.spoke_config.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value.address_prefix]
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-spoke-${var.spoke_config.environment}-to-hub"
  resource_group_name          = azurerm_resource_group.spoke.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

output "spoke_vnet_id" { value = azurerm_virtual_network.spoke.id }
