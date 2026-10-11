variable "attachments" {
  description = "Map of load balancer to network attachments. Map key is the logical name used for wiring."
  type = map(object({
    load_balancer_id        = number
    subnet_id               = optional(string)
    network_id              = optional(number)
    ip                      = optional(string)
    enable_public_interface = optional(bool, true)
  }))
  default = {}

  validation {
    condition     = alltrue([for a in var.attachments : (a.subnet_id != null) != (a.network_id != null)])
    error_message = "Each attachment must set exactly one of subnet_id or network_id. Without either, the load balancer is attached to the last subnet, ordered by ip_range, which is unpredictable."
  }
}