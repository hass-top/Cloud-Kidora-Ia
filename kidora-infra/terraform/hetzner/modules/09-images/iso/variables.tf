variable "isos" {
  description = "Map of ISO references to mount on a server. Map key is the logical name used for wiring."
  type = map(object({
    reference   = string
    description = optional(string, "")
    mount_point = optional(string, "/mnt/iso")
  }))
  default = {}

  validation {
    condition     = alltrue([for i in var.isos : length(trimspace(i.reference)) > 0])
    error_message = "An ISO reference must be a non-empty name or ID, for example \"virtio-win-0.1.240.iso\"."
  }

  validation {
    condition     = alltrue([for i in var.isos : startswith(i.mount_point, "/")])
    error_message = "mount_point must be an absolute path, for example \"/mnt/iso\"."
  }
}

variable "lookup_supported" {
  description = "Always false. Records that ISO resolution by name is unavailable in the provider, so a typo surfaces at boot rather than at plan."
  type        = bool
  default     = false
}