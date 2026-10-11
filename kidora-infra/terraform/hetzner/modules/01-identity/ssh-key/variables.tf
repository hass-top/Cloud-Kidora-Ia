variable "keys" {
  description = "Map of SSH keys to manage. Map key is the logical name used for wiring; value is the key definition."
  type = map(object({
    name       = string
    public_key = string
    labels     = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([
      for k in var.keys :
      can(regex("^(ssh-rsa|ssh-ed25519|ssh-dss|ecdsa-sha2-nistp[0-9]{3})\\s+[A-Za-z0-9+/=]+", trimspace(k.public_key)))
    ])
    error_message = "Each public_key must be a single OpenSSH public key line (ssh-rsa, ssh-ed25519, ssh-dss or ecdsa-sha2-*)."
  }

  validation {
    condition     = alltrue([for k in var.keys : length(trimspace(k.name)) > 0 && length(trimspace(k.name)) <= 63])
    error_message = "SSH key names must be between 1 and 63 characters."
  }
}

variable "labels" {
  description = "Labels applied to every SSH key created by this module."
  type        = map(string)
  default     = {}
}