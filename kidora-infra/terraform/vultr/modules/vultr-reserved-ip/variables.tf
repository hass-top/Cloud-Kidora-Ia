variable "region" {
  type        = string
  description = "Vultr region (e.g., fra)"
}

variable "label" {
  type        = string
  description = "Label for the reserved IP"
}

variable "ip_type" {
  type        = string
  default     = "v4"
  description = "IP type: v4 or v6"
}

variable "instance_id" {
  type        = string
  default     = null
  description = "Instance ID to attach the reserved IP to (optional)"
}