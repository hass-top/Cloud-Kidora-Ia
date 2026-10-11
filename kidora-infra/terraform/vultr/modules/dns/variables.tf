variable "domain" {
  description = "Domain name for DNS"
  type        = string
}

variable "ttl" {
  description = "TTL for DNS records"
  type        = number
  default     = 300
}

variable "region" {
  description = "Region for DNS domain"
  type        = string
  default     = "fra"
}

variable "records" {
  description = "List of DNS records to create"
  type = list(object({
    name     = string
    type     = string
    data     = string
    ttl      = number
    priority = optional(number)
  }))
  default = []
}
