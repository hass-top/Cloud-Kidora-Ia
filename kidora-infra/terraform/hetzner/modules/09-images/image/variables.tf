variable "images" {
  description = "Map of images to look up. Map key is the logical name used for wiring."
  type = map(object({
    id                 = optional(number)
    name               = optional(string)
    selector           = optional(string)
    architecture       = optional(string, "x86")
    most_recent        = optional(bool, true)
    include_deprecated = optional(bool, false)
  }))
  default = {}

  validation {
    condition     = alltrue([for i in var.images : length(compact([i.id, i.name, i.selector])) >= 1])
    error_message = "Each lookup must set at least one of id, name or selector, otherwise the query matches every image."
  }

  validation {
    condition     = alltrue([for i in var.images : length(compact([i.id, i.name])) <= 1])
    error_message = "id and name are mutually exclusive: set one, or use selector to pick among many."
  }

  validation {
    condition     = alltrue([for i in var.images : contains(["x86", "arm"], i.architecture)])
    error_message = "architecture must be either \"x86\" or \"arm\"."
  }
}