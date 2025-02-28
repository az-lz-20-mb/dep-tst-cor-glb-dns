variable "enable_telemetry" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
variable "resource groups " {
  type = map(object({
    rg = string
    location = string
  }))
}
variable "existing_vnets" {
  description = "Map of existing VNet; for proper functionality, the key of this map should be the location of the resource group."
  type = map(object({
    name           = string
    resource_group = string
  }))

}
