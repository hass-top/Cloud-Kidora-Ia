variable "routes" {
  description = "Map of routes to add to networks. Map key is the logical name used for wiring."
  type = map(object({
    network_id  = number
    destination = string
    gateway     = string
  }))
  default = {}

  validation {
    condition     = alltrue([for r in var.routes : can(cidrhost(r.destination, 0))])
    error_message = "Every route destination must be a valid CIDR block, and must be a subnet of the network ip_range."
  }

  validation {
    condition     = alltrue([for r in var.routes : can(cidrhost("${r.gateway}/32", 0))])
    error_message = "Every route gateway must be a bare IPv4 or IPv6 address without a prefix length."
  }

  validation {
    condition     = alltrue([for r in var.routes : r.gateway != "172.31.1.1"])
    error_message = "172.31.1.1 is reserved by Hetzner as the gateway for the public network interface and cannot be used as a route gateway."
  }
}