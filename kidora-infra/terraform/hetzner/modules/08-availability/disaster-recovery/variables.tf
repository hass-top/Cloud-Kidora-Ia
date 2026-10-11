variable "recovery_points" {
  description = "Map of snapshots intended as recovery points. Map key is the logical name used for wiring."
  type = map(object({
    snapshot_id = number
    description = optional(string)
    target_role = optional(string, "")
    rpo_minutes = optional(number, 1440)
    rto_minutes = optional(number, 120)
  }))
  default = {}
}

variable "primary_region" {
  description = "Region the primary workload runs in, recorded for cross-region decisions."
  type        = string
  default     = "eu-central"
}