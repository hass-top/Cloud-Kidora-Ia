variable "networks" {
  description = "Map of private networks to manage. Map key is the logical name used for wiring."
  type = map(object({
    name                     = string
    ip_range                 = string
    expose_routes_to_vswitch = optional(bool, false)
    delete_protection        = optional(bool, false)
    labels                   = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for n in var.networks : can(cidrhost(n.ip_range, 0))])
    error_message = "Every network ip_range must be a valid IPv4 or IPv6 CIDR block."
  }

  validation {
    condition     = alltrue([for n in var.networks : length(trimspace(n.name)) > 0 && length(trimspace(n.name)) <= 63])
    error_message = "Network names must be between 1 and 63 characters."
  }
}

variable "labels" {
  description = "Labels applied to every network created by this module."
  type        = map(string)
  default     = {}
}