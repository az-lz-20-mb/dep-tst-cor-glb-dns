terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-storage3"
    storage_account_name = "tfstatestorage3lz20"
    container_name       = "tfstate2"
    key                  = "terraform.tfstate"
  }

  required_version = "~> 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
        prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

module "naming" {
  source = "git::https://github.com/az-lz-20-mb/mod-tf-arm-naming.git"
  suffix = [local.environment, local.short_location, local.platform, local.type]
}

resource "azurerm_resource_group" "rg" {
  for_each = local.resource_groups

  name     = each.value.name
  location = each.value.location
}


data "azurerm_virtual_network" "existing_vnet_sweden" {
  name                = "vnet-tst-swc-net-01"
  resource_group_name = "rg-tst-swc-net-01"
}

data "azurerm_virtual_network" "existing_vnets" {
  for_each = var.existing_vnets

  name                = each.value.name
  resource_group_name = each.value.resource_group
}


module "private_dns_zones-1" {
  source                          = "git::https://github.com/az-lz-20-mb/mod-avm-res-network-privatelinkdnszone.git"
  for_each                        = local.resource_groups
  location                        = each.value.location
  resource_group_name             = each.value.name
  resource_group_creation_enabled = false
  enable_telemetry                = var.enable_telemetry


  virtual_network_resource_ids_to_link_to = {
  for key, vnet_data in local.vnets_with_ids : key => {
      vnet_resource_id =  vnet_data.id
 } if vnet_data.location == each.value.location
 
  }
}
