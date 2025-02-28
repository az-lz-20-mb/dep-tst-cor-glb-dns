locals {
  short_location = "gwc"
  environment    = "tst"
  platform       = "dns"
  type           = "zone"

  resource_groups = {
    "poland" = {
      name     = "${module.naming.resource_group.name}-poland1"
      location = "polandcentral"
    },
    "germany" = {
      name     = "${module.naming.resource_group.name}-germany1"
      location = "germanywestcentral"
    },
    "sweden" = {
      name     = "${module.naming.resource_group.name}-sweden1"
      location = "swedencentral"
    }
  }

   vnets_with_ids = {
    for k, v in var.existing_vnets : k => {
      id = data.azurerm_virtual_network.existing_vnets[k].id
      location =  data.azurerm_virtual_network.existing_vnets[k].location
    }
  }
  
  
}
