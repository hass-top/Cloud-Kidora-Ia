variable "subnets" {
  description = <<-EOT
    Map of subnets to manage. Map key is the logical name used for wiring.
    Note: hcloud_network_subnet does not support labels or VLAN ids. Subnet type
    "server" is an isolated network, but its VLAN is derived from the type rather
    than configured; only "vswitch" subnets take an explicit vswitch_id.
  EOT
  type = map(object({
    network_id   = number
    type         = optional(string, "cloud")
    network_zone = string
    ip_range     = string
    vswitch_id   = optional(number)
  }))
  default = {}

  validation {
    condition     = alltrue([for s in var.subnets : contains(["cloud", "server", "vswitch"], s.type)])
    error_message = "Subnet type must be one of \"cloud\", \"server\" or \"vswitch\"."
  }

  validation {
    condition     = alltrue([for s in var.subnets : can(cidrhost(s.ip_range, 0))])
    error_message = "Every subnet ip_range must be a valid IPv4 or IPv6 CIDR block."
  }

  validation {
    condition     = alltrue([for s in var.subnets : s.type == "vswitch" || s.vswitch_id == null])
    error_message = "vswitch_id may only be set on a subnet of type \"vswitch\"."
  }

  validation {
    condition     = alltrue([for s in var.subnets : s.type != "vswitch" || s.vswitch_id != null])
    error_message = "A subnet of type \"vswitch\" requires vswitch_id."
  }
}

variable "labels" {
  description = "Unused by hcloud_network_subnet, which exposes no labels field. Accepted so callers can stay uniform."
  type        = map(string)
  default     = {}
}