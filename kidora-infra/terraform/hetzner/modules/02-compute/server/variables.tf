variable "servers" {
  description = "Map of servers to manage. Map key is the logical name used for wiring; value is the server definition."
  type = map(object({
    name         = string
    server_type  = string
    location     = string
    image        = string
    iso          = optional(string)
    ssh_keys     = optional(list(number), [])
    firewall_ids = optional(list(number), [])
    labels       = optional(map(string), {})

    backups = optional(bool, false)

    placement_group_id       = optional(number)
    delete_protection        = optional(bool, false)
    rebuild_protection       = optional(bool, false)
    shutdown_before_deletion = optional(bool, true)
    keep_disk                = optional(bool, false)

    user_data = optional(string)

    ipv4_enabled    = optional(bool, true)
    ipv6_enabled    = optional(bool, true)
    primary_ipv4_id = optional(number)

    networks = optional(list(object({
      subnet_id = string
      ip        = optional(string)
      alias_ips = optional(list(string), [])
    })), [])
  }))
  default = {}

  validation {
    condition     = alltrue([for s in var.servers : can(regex("^[a-z0-9]([a-z0-9\\-]*[a-z0-9])?$", s.name)) && length(s.name) <= 63])
    error_message = "Server names must be a valid hostname: lowercase letters, digits and hyphens, not starting or ending with a hyphen, 63 characters maximum."
  }

  validation {
    condition     = alltrue([for s in var.servers : s.ipv4_enabled || s.ipv6_enabled])
    error_message = "At least one of ipv4_enabled or ipv6_enabled must be true, otherwise the server has no public network interface."
  }

  validation {
    condition     = alltrue([for s in var.servers : s.primary_ipv4_id == null || s.ipv4_enabled])
    error_message = "primary_ipv4_id requires ipv4_enabled to be true."
  }
}

variable "labels" {
  description = "Labels applied to every server created by this module."
  type        = map(string)
  default     = {}
}