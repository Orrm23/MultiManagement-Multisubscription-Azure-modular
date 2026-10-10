terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-mgmt-prod-001"
    storage_account_name = "sttfstatealzprod001"
    container_name       = "tfstate"
    key                  = "landingzone.terraform.tfstate"
  }
}

provider "azurerm" { features {} }

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = var.spoke_workloads["prod"].subscription_id
  features {}
}

provider "azurerm" {
  alias           = "management"
  subscription_id = var.spoke_workloads["prod"].subscription_id
  features {}
}
