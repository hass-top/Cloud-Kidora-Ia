variable "attachments" {
  description = "Map of volume attachments. Map key is the logical name used for wiring."
  type = map(object({
    volume_id = number
    server_id = number
    automount = optional(bool, true)
  }))
  default = {}
}