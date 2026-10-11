variable "protocol" {
  description = "Health check protocol. \"http\" probes a URL, \"tcp\" only probes that the port accepts connections."
  type        = string
  default     = "http"

  validation {
    condition     = contains(["http", "tcp"], var.protocol)
    error_message = "Health check protocol must be either \"http\" or \"tcp\"."
  }
}

variable "port" {
  description = "Port to probe when protocol is \"tcp\". Ignored for \"http\", which follows the service port."
  type        = number
  default     = null
  nullable    = true
}

variable "interval" {
  description = "Seconds between health checks."
  type        = number
  default     = 15

  validation {
    condition     = var.interval >= 5 && var.interval <= 3600
    error_message = "Health check interval must be between 5 and 3600 seconds."
  }
}

variable "timeout" {
  description = "Seconds before a check attempt is abandoned. Must be less than interval."
  type        = number
  default     = 10
}

variable "retries" {
  description = "Consecutive failures before a target is marked unhealthy."
  type        = number
  default     = 3

  validation {
    condition     = var.retries >= 1 && var.retries <= 5
    error_message = "Health check retries must be between 1 and 5."
  }
}

variable "http" {
  description = "HTTP probe details, used when protocol is \"http\"."
  type = object({
    domain       = optional(string)
    path         = optional(string, "/")
    response     = optional(string, "")
    tls          = optional(bool, false)
    status_codes = optional(list(string), ["2??", "3??"])
  })
  default = {}
}