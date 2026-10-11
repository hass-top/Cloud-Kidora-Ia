variable "rules" {
  description = "Firewall rules to normalise. Map key is the logical name used for wiring and in diagnostics."
  type = map(object({
    description     = optional(string)
    direction       = optional(string, "in")
    protocol        = string
    port            = optional(string, "any")
    source_ips      = optional(list(string), [])
    destination_ips = optional(list(string), [])
  }))
  default = {}

  validation {
    condition     = alltrue([for r in var.rules : contains(["in", "out"], r.direction)])
    error_message = "Rule direction must be either \"in\" or \"out\"."
  }

  validation {
    condition     = alltrue([for r in var.rules : contains(["tcp", "icmp", "udp", "gre", "esp"], r.protocol)])
    error_message = "Rule protocol must be one of \"tcp\", \"icmp\", \"udp\", \"gre\" or \"esp\"."
  }

  validation {
    condition     = alltrue([for r in var.rules : can(regex("^(any|[0-9]{1,5}(,[0-9]{1,5})*(-[0-9]{1,5})?)$", r.port))])
    error_message = "Port must be \"any\", a single port, a comma-separated list, or a range such as \"80-85\"."
  }

  validation {
    condition     = alltrue([for r in var.rules : r.direction != "in" || length(r.source_ips) > 0])
    error_message = "An inbound rule needs at least one entry in source_ips, for example [\"0.0.0.0/0\"]."
  }

  validation {
    condition     = alltrue([for r in var.rules : r.direction != "out" || length(r.destination_ips) > 0])
    error_message = "An outbound rule needs at least one entry in destination_ips."
  }
}