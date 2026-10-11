variable "targets" {
  description = "Map of load balancer targets. Map key is the logical name used for wiring."
  type = map(object({
    type             = string
    load_balancer_id = number
    server_id        = optional(number)
    label_selector   = optional(string)
    ip               = optional(string)
    use_private_ip   = optional(bool, false)
  }))
  default = {}

  validation {
    condition     = alltrue([for t in var.targets : contains(["server", "label_selector", "ip"], t.type)])
    error_message = "Target type must be one of \"server\", \"label_selector\" or \"ip\"."
  }

  validation {
    condition     = alltrue([for t in var.targets : t.type != "server" || t.server_id != null])
    error_message = "A target of type \"server\" requires server_id."
  }

  validation {
    condition     = alltrue([for t in var.targets : t.type != "label_selector" || (t.label_selector != null && trimspace(t.label_selector) != "")])
    error_message = "A target of type \"label_selector\" requires a non-empty label_selector."
  }

  validation {
    condition     = alltrue([for t in var.targets : t.type != "ip" || t.ip != null])
    error_message = "A target of type \"ip\" requires ip."
  }

  validation {
    condition     = alltrue([for t in var.targets : t.type == "ip" || !t.use_private_ip])
    error_message = "use_private_ip applies only to targets of type \"server\" or \"label_selector\"; an IP target has no private interface to use."
  }
}