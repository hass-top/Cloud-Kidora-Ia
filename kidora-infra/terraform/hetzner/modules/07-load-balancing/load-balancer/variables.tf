variable "load_balancers" {
  description = "Map of load balancers to manage. Map key is the logical name used for wiring."
  type = map(object({
    name               = string
    load_balancer_type = string
    location           = optional(string)
    network_zone       = optional(string)
    algorithm          = optional(string, "round_robin")
    delete_protection  = optional(bool, false)
    labels             = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for lb in var.load_balancers : (lb.location != null) != (lb.network_zone != null)])
    error_message = "Each load balancer must set exactly one of location (pinned to one location) or network_zone (spread across the zone)."
  }

  validation {
    condition     = alltrue([for lb in var.load_balancers : contains(["round_robin", "least_connections"], lb.algorithm)])
    error_message = "algorithm must be either \"round_robin\" or \"least_connections\"."
  }
}

variable "labels" {
  description = "Labels applied to every load balancer created by this module."
  type        = map(string)
  default     = {}
}