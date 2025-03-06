data "azurerm_client_config" "current" {}

module "naming" {
  source = "git::https://github.com/az-lz-20-mb/mod-tf-arm-naming.git"
  suffix = [local.short_location, local.environment, local.platform, local.type]
}

resource "azurerm_resource_group" "rg_private_dns" {
  name     = "${module.naming.resource_group.name}-01"
  location = var.resource_group_location
}

data "azurerm_virtual_network" "existing_vnets" {
  for_each = var.existing_vnets

  name                = each.value.name
  resource_group_name = each.value.resource_group
}

module "private_dns_zones" {
  source = "git::https://github.com/az-lz-20-mb/mod-avm-res-network-privatelinkdnszone.git"

  location                        = azurerm_resource_group.rg_private_dns.location
  resource_group_name             = azurerm_resource_group.rg_private_dns.name
  resource_group_creation_enabled = false
  enable_telemetry                = var.enable_telemetry


  virtual_network_resource_ids_to_link_to = {
    for key, vnet_data in local.vnets_with_ids : key => {
      vnet_resource_id = vnet_data.id
    }
  }
}
