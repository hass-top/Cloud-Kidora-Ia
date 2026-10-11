variable "name" {
  description = "Label for the object storage"
  type        = string
}

variable "region" {
  description = "Region where the object storage will be created"
  type        = string
}

variable "cluster" {
  description = "Cluster ID for the object storage"
  type        = number
  default     = 1
}

variable "tier" {
  description = "Storage tier (0 = Standard, 1 = Archive)"
  type        = number
  default     = 0
}
