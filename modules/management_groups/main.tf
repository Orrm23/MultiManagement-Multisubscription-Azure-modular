variable "root_id" { type = string }
variable "root_name" { type = string }
variable "subscription_ids" { type = map(string) }

resource "azurerm_management_group" "root" {
  display_name = var.root_name
  name         = var.root_id
}

resource "azurerm_management_group" "platform" {
  display_name               = "Platform Infrastructure"
  name                       = "${var.root_id}-platform"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "workloads" {
  display_name               = "Application Workloads"
  name                       = "${var.root_id}-workloads"
  parent_management_group_id = azurerm_management_group.root.id
}

output "root_mg_id" { value = azurerm_management_group.root.id }
