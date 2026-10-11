variable "services" {
  description = "Map of load balancer services. Map key is the logical name used for wiring."
  type = map(object({
    load_balancer_id = number
    protocol         = string
    listen_port      = optional(number)
    destination_port = optional(number)
    proxyprotocol    = optional(bool, false)

    sticky_sessions = optional(bool, false)
    cookie_name     = optional(string, "HCLBSTICKY")
    cookie_lifetime = optional(number, 300)
    redirect_http   = optional(bool, false)
    timeout_idle    = optional(number)
    certificates    = optional(list(number), [])

    health_check = optional(object({
      protocol = string
      port     = optional(number)
      interval = number
      timeout  = number
      retries  = number
      http = object({
        domain       = optional(string)
        path         = optional(string)
        response     = optional(string)
        tls          = optional(bool)
        status_codes = optional(list(string))
      })
    }))
  }))
  default = {}

  validation {
    condition     = alltrue([for s in var.services : contains(["http", "https", "tcp"], s.protocol)])
    error_message = "Service protocol must be one of \"http\", \"https\" or \"tcp\"."
  }

  validation {
    condition     = alltrue([for s in var.services : s.protocol != "tcp" || (s.listen_port != null && s.destination_port != null)])
    error_message = "A service of protocol \"tcp\" must set both listen_port and destination_port."
  }

  validation {
    condition     = alltrue([for s in var.services : s.protocol != "https" || length(s.certificates) > 0])
    error_message = "A service of protocol \"https\" must reference at least one certificate, otherwise clients get a TLS error."
  }

  validation {
    condition     = alltrue([for s in var.services : s.health_check == null || s.health_check.timeout < s.health_check.interval])
    error_message = "The health check timeout must be shorter than its interval, otherwise checks overlap."
  }
}