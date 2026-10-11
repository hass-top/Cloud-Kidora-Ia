variable "hostname" {
  description = "Hostname to set on the node."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9\\-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9\\-]*[a-z0-9])?)*$", var.hostname)) && length(var.hostname) <= 63
    error_message = "hostname must be a valid lowercase hostname, 63 characters maximum."
  }
}

variable "user_name" {
  description = "Unprivileged user created on the node."
  type        = string
  default     = "kidora"

  validation {
    condition     = can(regex("^[a-z_][a-z0-9_\\-]*$", var.user_name))
    error_message = "user_name must be a lowercase POSIX username."
  }
}

variable "ssh_authorized_keys" {
  description = "Public keys granted sudo on the node. An empty list leaves only key-based root access, which breaks cloud-init if the wrong key was supplied."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.ssh_authorized_keys) > 0
    error_message = "At least one SSH key is required, otherwise the node cannot be reached after boot."
  }
}

variable "timezone" {
  description = "System timezone."
  type        = string
  default     = "UTC"
}

variable "manage_etc_hosts" {
  description = "Let cloud-init manage /etc/hosts so the hostname resolves locally."
  type        = bool
  default     = true
}

variable "packages" {
  description = "Packages installed on every boot."
  type        = list(string)
  default     = ["ca-certificates", "curl", "chrony", "jq"]
}

variable "environment" {
  description = "Environment name written to /etc/environment, so later tooling knows where it is running."
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name written to /etc/environment."
  type        = string
  default     = "kidora"
}

variable "node_exporter" {
  description = "Value written as NODE_EXPORTER_ENABLED. Set to \"true\" on hosts that should be scraped. Left null the variable is omitted entirely."
  type        = string
  default     = null
  nullable    = true
}

variable "additional_user_data" {
  description = "Extra cloud-init fragments, for example the output of 04-security/ssh-hardening. Each must be a complete YAML document."
  type        = list(string)
  default     = []
}