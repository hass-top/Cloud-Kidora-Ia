variable "attachments" {
  description = "Map of firewall attachments. Map key is the logical name, which must be unique per firewall."
  type = map(object({
    firewall_id     = number
    server_ids      = optional(list(number), [])
    label_selectors = optional(list(string), [])
  }))
  default = {}

  validation {
    condition     = alltrue([for a in var.attachments : length(a.server_ids) > 0 || length(a.label_selectors) > 0])
    error_message = "Each attachment must reference at least one server_id or one label_selector; an empty attachment protects nothing."
  }
}