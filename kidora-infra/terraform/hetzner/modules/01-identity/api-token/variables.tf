variable "token" {
  description = "Hetzner Cloud API token. Leave null to rely on the HCLOUD_TOKEN environment variable instead."
  type        = string
  default     = null
  nullable    = true
  sensitive   = true

  validation {
    condition     = var.token == null || can(regex("^[0-9a-f]{64}$", var.token))
    error_message = "A Hetzner Cloud API token is 64 lowercase hexadecimal characters."
  }
}

variable "required" {
  description = "Fail the plan when no token was supplied. Disable in modules that are purely declarative."
  type        = bool
  default     = true
}

variable "env_var_name" {
  description = "Name of the environment variable the hcloud provider reads its token from."
  type        = string
  default     = "HCLOUD_TOKEN"
}

variable "fingerprint_length" {
  description = "Number of hex characters of the token hash to expose in outputs."
  type        = number
  default     = 12

  validation {
    condition     = var.fingerprint_length >= 8 && var.fingerprint_length <= 64
    error_message = "fingerprint_length must be between 8 and 64."
  }
}