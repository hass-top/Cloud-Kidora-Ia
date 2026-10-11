variable "snapshots" {
  description = "Map of server snapshots to create. Map key is the logical name used for wiring."
  type = map(object({
    server_id   = number
    description = optional(string)
    labels      = optional(map(string), {})
  }))
  default = {}
}

variable "labels" {
  description = "Labels applied to every snapshot created by this module."
  type        = map(string)
  default     = {}
}