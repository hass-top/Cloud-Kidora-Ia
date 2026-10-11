variable "placement_groups" {
  description = "Map of placement groups to manage. Map key is the logical name used for wiring."
  type = map(object({
    name   = string
    labels = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = length(var.placement_groups) <= 10
    error_message = "A placement group of type \"spread\" holds at most 10 servers, so more than 10 groups is never meaningful."
  }
}

variable "type" {
  description = "Placement group type. \"spread\" distributes members across different physical hosts."
  type        = string
  default     = "spread"

  validation {
    condition     = var.type == "spread"
    error_message = "The only placement group type supported by Hetzner Cloud is \"spread\"."
  }
}

variable "labels" {
  description = "Labels applied to every placement group created by this module."
  type        = map(string)
  default     = {}
}