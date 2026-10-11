variable "floating_ips" {
  description = "Map of floating IPs to manage. Map key is the logical name used for wiring."
  type = map(object({
    type              = optional(string, "ipv4")
    name              = optional(string)
    server_id         = optional(number)
    home_location     = optional(string)
    description       = optional(string, "")
    delete_protection = optional(bool, false)
    labels            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for f in var.floating_ips : contains(["ipv4", "ipv6"], f.type)])
    error_message = "Floating IP type must be either \"ipv4\" or \"ipv6\"."
  }

  validation {
    condition     = alltrue([for f in var.floating_ips : (f.server_id != null) != (f.home_location != null)])
    error_message = "Each floating IP must set exactly one of server_id (bind immediately) or home_location (create unassigned). Both is an error, and so is neither."
  }

  validation {
    condition     = alltrue([for f in var.floating_ips : f.name == null || (length(trimspace(f.name)) > 0 && length(trimspace(f.name)) <= 63)])
    error_message = "When set, a floating IP name must be between 1 and 63 characters."
  }
}

variable "labels" {
  description = "Labels applied to every floating IP created by this module."
  type        = map(string)
  default     = {}
}