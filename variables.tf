
variable "resource_group_name" {
  description = "A container that holds related resources for an Azure solution"
  default     = "test-rg"
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  default     = "eastus"
}

variable "log_workspace_name" {
  description = "The name of the log analytics workspace to which you would store diagnostic logs"
  type        = string
  default = null
}

variable "key_vault_name" {
  description = "The Name of the key vault"
  default     = "keyvault-name"
}

variable "key_vault_sku_pricing_tier" {
  description = "The name of the SKU used for the Key Vault. The options are: `Standard`, `Premium`."
  default     = "Standard"
}

variable "enable_purge_protection" {
  description = "Is Purge Protection enabled for this Key Vault?"
  default     = false
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted. The valid value can be between 7 and 90 days"
  default     = 30
}
variable "prefix" {
  description = "(Optional) The dns prefix for the resources created in the specified Azure Resource Group"
  type = string
  default = "papi"
}



variable "appname" {
  description = "(Required) The appname prefix for the resources created in the specified Azure Resource Group"
  type = string
  default = "papi"
}
variable "env" {
  description = "(Required) Environment of the key vault"
  type = string
  default = "nonprod"
}

variable "postfix" {
  description = "(optional) The prpostfixefix for the resources created in the specified Azure Resource Group"
  type = string
 default = ""
}
variable "access_policies" {
  description = "List of access policies for the Key Vault."
  default     = []
}

variable "network_acls" {
  description = "Network rules to apply to key vault."
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "enable_private_endpoint" {
  description = "Manages a Private Endpoint to Azure Container Registry"
  default     = false
}

variable "private_service_connection_name" {
  description = "Name of the private service connection name"
  default     = null
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  default     = null
}

variable "existing_vnet_id" {
  description = "The resoruce id of existing Virtual network"
  default     = null
}

variable "existing_subnet_id" {
  description = "The resource id of existing subnet"
  default     = null
}

variable "private_subnet_address_prefix" {
  description = "address prefix of the subnet for private endpoints"
  default     = null
}

variable "private_dns_zone_name" {
  description = "Name of the existing private DNS zone"
  default     = null
}

variable "existing_private_dns_zone" {
  description = "Name of the existing private DNS zone"
  default     = null
}



variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}