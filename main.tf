module "management_groups" {
  source           = "./modules/management_groups"
  root_id          = var.root_id
  root_name        = "Contoso Global Landing Zones"
  subscription_ids = { for k, v in var.spoke_workloads : k => v.subscription_id }
}

module "hub_network" {
  source               = "./modules/hub_network"
  providers            = { azurerm = azurerm.connectivity }
  location             = var.location
  resource_group_name  = "rg-hub-connectivity-001"
  hub_vnet_cidr        = ["10.0.0.0/16"]
  firewall_subnet_cidr = "10.0.1.0/24"
  gateway_subnet_cidr  = "10.0.2.0/24"
  bastion_subnet_cidr  = "10.0.3.0/24"
}

module "observability" {
  source              = "./modules/observability"
  providers           = { azurerm = azurerm.management }
  location            = var.location
  resource_group_name = "rg-management-observability-001"
}

module "spoke_vending" {
  for_each            = var.spoke_workloads
  source              = "./modules/spoke_vending"
  spoke_config        = each.value
  location            = var.location
  hub_vnet_id         = module.hub_network.hub_vnet_id
  hub_vnet_name       = module.hub_network.hub_vnet_name
  hub_rg_name         = module.hub_network.hub_resource_group_name
  firewall_private_ip = module.hub_network.firewall_private_ip
}

module "policy_remediation" {
  source              = "./modules/policy_remediation"
  management_group_id = module.management_groups.root_mg_id
  dcr_id              = module.observability.dcr_id
}
