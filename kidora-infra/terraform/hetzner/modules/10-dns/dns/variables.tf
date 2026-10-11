variable "zone" {
  description = "Name or ID of the Hetzner zone these records belong to."
  type        = string
}

variable "recordsets" {
  description = "Map of record sets. The map key must be unique per name and type, for example \"app\", \"app-txt\"."
  type = map(object({
    name              = string
    type              = string
    ttl               = optional(number, 10800)
    change_protection = optional(bool, false)
    labels            = optional(map(string), {})
    records = list(object({
      value   = string
      comment = optional(string)
    }))
  }))
  default = {}

  validation {
    condition     = alltrue([for r in var.recordsets : contains(["A", "AAAA", "CNAME", "MX", "TXT", "SRV", "CAA", "NS", "PTR"], r.type)])
    error_message = "Record type must be one of A, AAAA, CNAME, MX, TXT, SRV, CAA, NS or PTR."
  }

  validation {
    condition     = alltrue([for r in var.recordsets : length(r.records) > 0])
    error_message = "Every record set needs at least one record. An empty set is rejected by the API."
  }

  validation {
    condition     = alltrue([for r in var.recordsets : r.type != "A" || alltrue([for rec in r.records : can(cidrhost("${rec.value}/32", 0))])])
    error_message = "An A record value must be a bare IPv4 address."
  }

  validation {
    condition     = alltrue([for r in var.recordsets : r.type != "AAAA" || alltrue([for rec in r.records : can(cidrhost("${rec.value}/128", 0))])])
    error_message = "An AAAA record value must be a bare IPv6 address."
  }

  validation {
    condition     = alltrue([for r in var.recordsets : alltrue([for rec in r.records : length(rec.value) <= 255])])
    error_message = "Each record value must be 255 characters or fewer. The API splits longer TXT values into quoted strings."
  }

  validation {
    condition     = alltrue([for r in var.recordsets : r.type != "SOA"])
    error_message = "SOA records are created and incremented by the Hetzner API. Declaring one will fight the API over the serial number."
  }
}

variable "labels" {
  description = "Labels applied to every record set created by this module."
  type        = map(string)
  default     = {}
}