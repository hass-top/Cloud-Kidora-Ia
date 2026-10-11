variable "assignments" {
  description = "Map of floating IP to server assignments. Map key is the logical name used for wiring."
  type = map(object({
    floating_ip_id = number
    server_id      = number
  }))
  default = {}
}