variable "primary_ips" {
  description = "Map of primary IPs to manage. Map key is the logical name used for wiring."
  type = map(object({
    name              = string
    type              = optional(string, "ipv4")
    location          = string
    assignee_type     = optional(string, "server")
    assignee_id       = optional(number)
    auto_delete       = optional(bool, true)
    delete_protection = optional(bool, false)
    labels            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for p in var.primary_ips : contains(["ipv4", "ipv6"], p.type)])
    error_message = "Primary IP type must be either \"ipv4\" or \"ipv6\"."
  }

  validation {
    condition     = alltrue([for p in var.primary_ips : contains(["server", "load_balancer"], p.assignee_type)])
    error_message = "assignee_type must be either \"server\" or \"load_balancer\"."
  }

  validation {
    condition     = alltrue([for p in var.primary_ips : length(trimspace(p.name)) > 0 && length(trimspace(p.name)) <= 63])
    error_message = "Primary IP names must be between 1 and 63 characters."
  }

  # No validation on auto_delete: pre-creating an unassigned Primary IP with
  # auto_delete = true is the normal pattern. The address is created standalone,
  # then handed to 02-compute/server, and is removed with the server it was
  # assigned to. Requiring assignee_id here would defeat the purpose of the module.
}

variable "labels" {
  description = "Labels applied to every primary IP created by this module."
  type        = map(string)
  default     = {}
}