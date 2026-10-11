variable "volumes" {
  description = "Map of block storage volumes to manage. Map key is the logical name used for wiring."
  type = map(object({
    name              = string
    size              = number
    location          = optional(string)
    server_id         = optional(number)
    automount         = optional(bool, false)
    format            = optional(string, "ext4")
    delete_protection = optional(bool, false)
    labels            = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for v in var.volumes : (v.location != null) != (v.server_id != null)])
    error_message = "Each volume must set exactly one of location (create unattached) or server_id (create and attach in one step)."
  }

  validation {
    condition     = alltrue([for v in var.volumes : contains(["ext4", "xfs"], v.format)])
    error_message = "Volume format must be either \"ext4\" or \"xfs\"."
  }

  validation {
    condition     = alltrue([for v in var.volumes : v.size >= 10 && v.size <= 10240])
    error_message = "Volume size must be between 10 GB and 10240 GB, the range Hetzner accepts."
  }
}

variable "labels" {
  description = "Labels applied to every volume created by this module."
  type        = map(string)
  default     = {}
}