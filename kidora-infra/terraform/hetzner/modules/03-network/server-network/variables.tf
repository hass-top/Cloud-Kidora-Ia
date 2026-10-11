variable "attachments" {
  description = "Map of server-to-network attachments. Map key is the logical name used for wiring."
  type = map(object({
    server_id  = number
    subnet_id  = optional(string)
    network_id = optional(number)
    ip         = optional(string)
    alias_ips  = optional(set(string), [])
  }))
  default = {}

  validation {
    condition     = alltrue([for a in var.attachments : (a.subnet_id != null) != (a.network_id != null)])
    error_message = "Each attachment must set exactly one of subnet_id or network_id. Prefer subnet_id: without it the server is attached to the last subnet, ordered by ip_range, which is unpredictable."
  }

  validation {
    condition     = alltrue([for a in var.attachments : a.ip == null || can(cidrhost("${a.ip}/32", 0))])
    error_message = "Each attachment ip must be a bare IPv4 or IPv6 address without a prefix length."
  }
}