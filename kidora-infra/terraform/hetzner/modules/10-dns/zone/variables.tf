variable "zones" {
  description = "Map of DNS zones to manage. Map key is the logical name used for wiring."
  type = map(object({
    name = string
    mode = optional(string, "primary")
    ttl  = optional(number, 10800)
    primary_nameservers = optional(list(object({
      address        = string
      port           = optional(number)
      tsig_algorithm = optional(string)
      tsig_key       = optional(string)
    })), [])
    delete_protection = optional(bool, false)
    labels            = optional(map(string), {})
  }))
  default = {}

  validation {
    # The length bound is a separate condition on purpose: Terraform uses RE2,
    # which has no lookahead assertions, so a (?=...) guard would make can(regex())
    # return false for every input and reject all zone names.
    condition     = alltrue([for z in var.zones : can(regex("^([a-z0-9]([a-z0-9\\-]*[a-z0-9])?\\.)+[a-z]{2,63}$", z.name)) && length(z.name) <= 253])
    error_message = "Zone names must be lowercase fully qualified domain names of at most 253 characters, for example \"kidora-prod.com\"."
  }

  validation {
    condition     = alltrue([for z in var.zones : contains(["primary", "secondary"], z.mode)])
    error_message = "Zone mode must be either \"primary\" or \"secondary\"."
  }

  validation {
    condition     = alltrue([for z in var.zones : (z.mode == "secondary") == (length(z.primary_nameservers) > 0)])
    error_message = "primary_nameservers is required when mode is \"secondary\" and forbidden when mode is \"primary\"."
  }
}

variable "labels" {
  description = "Labels applied to every zone created by this module."
  type        = map(string)
  default     = {}
}