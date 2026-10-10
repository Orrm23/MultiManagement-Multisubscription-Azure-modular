variable "management_group_id" { type = string }
variable "dcr_id" { type = string }

resource "azurerm_management_group_policy_assignment" "auto_ama" {
  name                 = "assign-auto-ama-agent"
  management_group_id  = var.management_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/9a501c59-a7e6-4277-bf30-edc93ab7e20e"
  display_name         = "Auto-Deploy Azure Monitor Agent (AMA)"
  location             = "eastus2"

  identity {
    type = "SystemAssigned"
  }
}
