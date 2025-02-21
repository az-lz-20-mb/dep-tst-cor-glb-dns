terraform {
  backend "azurerm" {
    storage_account_name = "tfstatestorage2lz20"
    container_name       = "tfstate4"
    key                  = "terraform.tfstate"
    resource_group_name  = "tfstate-storage2"
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

# 🔹 Grupy zasobów dla każdego regionu
resource "azurerm_resource_group" "rg_germany" {
  name     = "${module.naming.resource_group.name}-germany"
  location = "germanywestcentral"
}

resource "azurerm_resource_group" "rg_poland" {
  name     = "${module.naming.resource_group.name}-poland"
  location = "polandcentral"
}

resource "azurerm_resource_group" "rg_sweden" {
  name     = "${module.naming.resource_group.name}-sweden"
  location = "swedencentral"
}

# 🔹 Pobranie istniejących Virtual Networków i przypisanie do odpowiednich RG
data "azurerm_virtual_network" "existing_vnet_germany" {
  name                = "vnet-tst-shd-hub-net-01"
  resource_group_name = "rg-tst-shd-hub-net-01"
}

data "azurerm_virtual_network" "existing_vnet_poland" {
  name                = "vnet-tst-shd-hub-net-02"
  resource_group_name = "rg-tst-shd-hub-net-01"
}

data "azurerm_virtual_network" "existing_vnet_sweden" {
  name                = "vnet-tst-shd-hub-net-03"
  resource_group_name = "rg-tst-shd-hub-net-01"
}

# 🔹 Private DNS Zones w każdym regionie
module "private_dns_zones_germany" {
  source  = "git::https://github.com/az-lz-20-mb/mod-avm-res-network-privatelinkdnszone.git"

  location            = azurerm_resource_group.rg_germany.location
  resource_group_name = azurerm_resource_group.rg_germany.name

  resource_group_creation_enabled = false

  virtual_network_resource_ids_to_link_to = {
    "existing_vnet_germany" = {
      vnet_resource_id = data.azurerm_virtual_network.existing_vnet_germany.id
    }
  }

  enable_telemetry = var.enable_telemetry
}

module "private_dns_zones_poland" {
  source  = "git::https://github.com/az-lz-20-mb/mod-avm-res-network-privatelinkdnszone.git"

  location            = azurerm_resource_group.rg_poland.location
  resource_group_name = azurerm_resource_group.rg_poland.name

  resource_group_creation_enabled = false

  virtual_network_resource_ids_to_link_to = {
    "existing_vnet_poland" = {
      vnet_resource_id = data.azurerm_virtual_network.existing_vnet_poland.id
    }
  }

  enable_telemetry = var.enable_telemetry
}

module "private_dns_zones_sweden" {
  source  = "git::https://github.com/az-lz-20-mb/mod-avm-res-network-privatelinkdnszone.git"

  location            = azurerm_resource_group.rg_sweden.location
  resource_group_name = azurerm_resource_group.rg_sweden.name

  resource_group_creation_enabled = false

  virtual_network_resource_ids_to_link_to = {
    "existing_vnet_sweden" = {
      vnet_resource_id = data.azurerm_virtual_network.existing_vnet_sweden.id
    }
  }

  enable_telemetry = var.enable_telemetry
}
