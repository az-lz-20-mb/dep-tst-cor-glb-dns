locals {
  short_location = "gwc"
  environment    = "tst"
  platform       = "dns"
  type           = "zone"

   vnets_with_ids = {
    for k, v in var.existing_vnets : k => {
      id = data.azurerm_virtual_network.existing_vnets[k].id
      location =  data.azurerm_virtual_network.existing_vnets[k].location
    }
  }
  
  
}
