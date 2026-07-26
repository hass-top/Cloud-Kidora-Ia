variable "vultr_api_key" {
  description = "Vultr API token"
  type        = string
  sensitive   = true
}


variable "region" {
  description = "Vultr region"
  type        = string
  default     = "fra"
}


variable "plan" {
  description = "Vultr instance plan"
  type        = string
  default     = "vc2-1c-2gb"
}

variable "os_id" {
  description = "Ubuntu 24.04"
  type        = number
  default     = 2284
}


variable "server_name" {
  type    = string
  default = "kidora-dev-server"
}

variable "ssh_key_name" {
  description = "Name of the SSH key"
  type        = string
  default     = "kidora_ssh"
}

variable "ssh_public_key" {
  description = "Public key content for SSH access"
  type        = string
}


variable "dns_domain" {
  description = "DNS domain name"
  type        = string
  default     = "kidora-dev.com"
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
