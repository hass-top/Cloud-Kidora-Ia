variable "entries" {
  description = "Map of reverse DNS entries. Map key is the logical name used for wiring."
  type = map(object({
    server_id        = optional(number)
    primary_ip_id    = optional(number)
    floating_ip_id   = optional(number)
    load_balancer_id = optional(number)
    ip_address       = string
    dns_ptr          = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for e in var.entries :
      length(compact([e.server_id, e.primary_ip_id, e.floating_ip_id, e.load_balancer_id])) == 1
    ])
    error_message = "Each entry must set exactly one of server_id, primary_ip_id, floating_ip_id or load_balancer_id."
  }

  validation {
    condition     = alltrue([for e in var.entries : can(regex("^([a-z0-9]([a-z0-9\\-]{0,61}[a-z0-9])?\\.)+[a-z]{2,63}\\.?$", e.dns_ptr))])
    error_message = "dns_ptr must be a hostname, for example \"app.kidora-prod.com\"."
  }
}