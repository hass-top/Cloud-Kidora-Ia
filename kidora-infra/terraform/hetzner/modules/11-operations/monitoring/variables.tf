variable "targets" {
  description = "Map of scrape targets, normally derived from the output of 02-compute/server."
  type = map(object({
    name   = string
    ip     = optional(string)
    role   = optional(string, "unknown")
    port   = optional(number, 9100)
    path   = optional(string, "/metrics")
    scheme = optional(string, "http")
    scrape = optional(bool, true)
  }))
  default = {}

  validation {
    condition     = alltrue([for t in var.targets : contains(["http", "https"], t.scheme)])
    error_message = "scheme must be either \"http\" or \"https\"."
  }

  validation {
    condition     = alltrue([for t in var.targets : t.port >= 1 && t.port <= 65535])
    error_message = "Port must be between 1 and 65535."
  }
}

variable "environment" {
  description = "Environment these targets belong to, used in job and instance labels."
  type        = string
  default     = "dev"
}

variable "selector" {
  description = "Label selector that identifies the managed hosts, usually the output of 11-operations/labels.environment_selector."
  type        = string
  default     = null
}

variable "scrape_interval" {
  description = "Seconds between scrapes."
  type        = string
  default     = "30s"

  validation {
    condition     = can(regex("^[0-9]+(ms|s|m|h)$", var.scrape_interval))
    error_message = "scrape_interval must be a Prometheus duration such as \"30s\" or \"1m\"."
  }
}

variable "scrape_timeout" {
  description = "Per-scrape timeout. Must not exceed scrape_interval."
  type        = string
  default     = "10s"

  validation {
    condition     = var.scrape_timeout != var.scrape_interval
    error_message = "scrape_timeout must be shorter than scrape_interval."
  }
}