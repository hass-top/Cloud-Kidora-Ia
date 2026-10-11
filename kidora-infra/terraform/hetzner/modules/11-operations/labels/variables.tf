variable "project" {
  description = "Project name, used as a label on every resource."
  type        = string
  default     = "kidora"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9_\\-.]*[a-z0-9])?$", var.project)) && length(var.project) <= 63
    error_message = "Labels must match [a-z0-9] with dashes, underscores and dots, 63 characters maximum."
  }
}

variable "environment" {
  description = "Environment name, for example \"dev\", \"preprod\" or \"prod\"."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9_\\-.]*[a-z0-9])?$", var.environment)) && length(var.environment) <= 63
    error_message = "Labels must match [a-z0-9] with dashes, underscores and dots, 63 characters maximum."
  }
}

variable "role" {
  description = "Role of the resource, for example \"app\", \"database\" or \"monitoring\". Leave null for resources that are not part of a role group."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.role == null || (can(regex("^[a-z0-9]([a-z0-9_\\-.]*[a-z0-9])?$", var.role)) && length(var.role) <= 63)
    error_message = "Labels must match [a-z0-9] with dashes, underscores and dots, 63 characters maximum."
  }
}

variable "extra" {
  description = "Additional labels merged into the base set. Use for cost centres, compliance or ownership."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.extra : can(regex("^[a-z0-9]([a-z0-9_\\-.]*[a-z0-9])?$", k)) && can(regex("^[a-zA-Z0-9]([a-zA-Z0-9_\\-.]*[a-zA-Z0-9])?$", v))])
    error_message = "Label keys must be lowercase and match [a-z0-9] with dashes, underscores and dots. Values allow uppercase too."
  }
}

variable "extra_selectors" {
  description = "Additional ready-made selectors, for label sets this module does not own."
  type        = map(string)
  default     = {}
}