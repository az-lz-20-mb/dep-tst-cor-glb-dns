variable "enable_telemetry" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}
variable "existing_vnets" {
  description = "Map of existing VNets"
  type = map(object({
    name           = string
    resource_group = string
  }))

}
variable "resource_group_location" {
  description = "Location of resource group."
  type = string
}

