provider "azurerm" {
  features {}
}

terraform {
 
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.7.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.59.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
  required_version = ">= 0.13"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                            = var.key_vault_name == null ? "${var.appname}${var.postfix}-${var.location}-${var.env}-kv" : var.key_vault_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_pricing_tier
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.enable_purge_protection
  tags                            = merge({ "ResourceName" = lower("kv-${var.key_vault_name}") }, var.tags, )

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }

   dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }
}
  

data "azurerm_virtual_network" "vnet01" {
  count               = var.enable_private_endpoint && var.existing_vnet_id == null ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "snet-ep" {
  count                                          = var.enable_private_endpoint && var.existing_subnet_id == null ? 1 : 0
  name                                           = "snet-endpoint-${var.location}"
  resource_group_name                            = var.existing_vnet_id == null ? data.azurerm_virtual_network.vnet01.0.resource_group_name : element(split("/", var.existing_vnet_id), 4)
  virtual_network_name                           = var.existing_vnet_id == null ? data.azurerm_virtual_network.vnet01.0.name : element(split("/", var.existing_vnet_id), 8)
  address_prefixes                               = var.private_subnet_address_prefix
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_private_endpoint" "pep1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-private-endpoint", var.key_vault_name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.existing_subnet_id == null ? azurerm_subnet.snet-ep.0.id : var.existing_subnet_id
  tags                = merge({ "Name" = format("%s-private-endpoint", var.key_vault_name) }, var.tags, )

  private_service_connection {
    name                           = var.private_service_connection_name
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

data "azurerm_private_endpoint_connection" "private-ip1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep1.0.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_key_vault.main]
}

resource "azurerm_private_dns_zone" "dnszone1" {
  count               = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = merge({ "Name" = format("%s", "KeyVault-Private-DNS-Zone") }, var.tags, )
}

resource "azurerm_private_dns_a_record" "arecord1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_key_vault.main.name
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1.0.name : var.existing_private_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip1.0.private_service_connection.0.private_ip_address]
}
