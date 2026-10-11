variable "certificates" {
  description = <<-EOT
    Map of TLS certificates. Map key is the logical name used for wiring.
    NOT marked sensitive: an uploaded private_key is written to state in plaintext
    regardless, so protect the state backend rather than relying on masking.
  EOT
  type = map(object({
    type         = optional(string, "managed")
    name         = string
    domain_names = optional(list(string), [])
    certificate  = optional(string, "")
    private_key  = optional(string, "")
    labels       = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for c in var.certificates : contains(["managed", "uploaded"], c.type)])
    error_message = "Certificate type must be either \"managed\" or \"uploaded\"."
  }

  validation {
    condition     = alltrue([for c in var.certificates : c.type != "managed" || length(c.domain_names) > 0])
    error_message = "A certificate of type \"managed\" requires at least one entry in domain_names."
  }

  validation {
    condition     = alltrue([for c in var.certificates : c.type != "uploaded" || (length(trimspace(c.certificate)) > 0 && length(trimspace(c.private_key)) > 0)])
    error_message = "A certificate of type \"uploaded\" requires both certificate and private_key."
  }
}

variable "labels" {
  description = "Labels applied to every certificate created by this module."
  type        = map(string)
  default     = {}
}