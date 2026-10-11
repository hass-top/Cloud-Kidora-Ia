variable "vultr_api_key" {
  type      = string
  sensitive = true
}


variable "region" {
  type = string
}

variable "plan" {
  type = string
}

variable "os_id" {
  type = number
}

variable "ssh_key_name" {
  description = "Name of the SSH key"
  type        = string
  default     = "kidora-prod-key"
}

variable "ssh_public_key" {
  description = "Public key content for SSH access"
  type        = string
}

variable "volume_size" {
  description = "Size of the block storage volume in GB"
  type        = number
  default     = 40
}

variable "storage_cluster" {
  description = "Cluster ID for object storage"
  type        = number
  default     = 1
}

variable "dns_domain" {
  description = "DNS domain name"
  type        = string
  default     = "kidora-prod.com"
}

variable "dns_records" {
  description = "List of DNS records"
  type = list(object({
    name     = string
    type     = string
    data     = string
    ttl      = number
    priority = optional(number)
  }))
  default = []
}
