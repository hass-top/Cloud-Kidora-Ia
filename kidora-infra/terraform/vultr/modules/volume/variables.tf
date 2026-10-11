variable "name" {
  description = "Label for the block storage volume"
  type        = string
}

variable "region" {
  description = "Region where the volume will be created"
  type        = string
}

variable "size" {
  description = "Size of the volume in GB"
  type        = number
  default     = 10
}

variable "block_type" {
  description = "Block storage type (e.g. block_storage_optical or block_storage_hdd)"
  type        = string
  default     = "block_storage_optical"
}

variable "mount_path" {
  description = "Mount path for the volume (optional)"
  type        = string
  default     = null
}
