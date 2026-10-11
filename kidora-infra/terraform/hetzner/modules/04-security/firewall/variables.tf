variable "firewalls" {
  description = "Map of firewalls to manage. Map key is the logical name used for wiring."
  type = map(object({
    name   = string
    labels = optional(map(string), {})

    rules = list(object({
      direction       = string
      protocol        = string
      port            = string
      source_ips      = list(string)
      destination_ips = list(string)
      description     = string
    }))

    apply_to = optional(object({
      label_selector = optional(string)
      server_id      = optional(number)
    }))
  }))
  default = {}

  validation {
    condition     = alltrue([for f in var.firewalls : (f.apply_to == null) || ((f.apply_to.label_selector != null) != (f.apply_to.server_id != null))])
    error_message = "apply_to accepts exactly one of label_selector or server_id, never both."
  }

  validation {
    condition     = alltrue([for f in var.firewalls : length(f.name) > 0 && length(f.name) <= 63])
    error_message = "Firewall names must be between 1 and 63 characters."
  }
}

variable "labels" {
  description = "Labels applied to every firewall created by this module."
  type        = map(string)
  default     = {}
}