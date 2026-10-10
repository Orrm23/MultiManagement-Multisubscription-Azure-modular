variable "location" { type = string }
variable "resource_group_name" { type = string }

resource "azurerm_resource_group" "obs" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-central-platform-001"
  location            = azurerm_resource_group.obs.location
  resource_group_name = azurerm_resource_group.obs.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

resource "azurerm_monitor_data_collection_rule" "dcr_platform" {
  name                = "dcr-central-os-logs"
  resource_group_name = azurerm_resource_group.obs.name
  location            = azurerm_resource_group.obs.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "central-law-dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog", "Microsoft-WindowsEvent"]
    destinations = ["central-law-dest"]
  }
}

output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.law.id }
output "dcr_id" { value = azurerm_monitor_data_collection_rule.dcr_platform.id }
