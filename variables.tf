variable "location" {
  type        = string
  default     = "eastus2"
  description = "Primary Azure region."
}

variable "root_id" {
  type        = string
  default     = "contoso"
  description = "Enterprise Root Management Group ID."
}

variable "spoke_workloads" {
  type = map(object({
    environment     = string
    subscription_id = string
    vnet_cidr       = list(string)
    subnets = map(object({
      address_prefix   = string
      delegation       = optional(string)
    }))
    enable_aks_subnet = bool
  }))
  description = "Dynamic spoke workloads matrix."
}
