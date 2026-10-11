variable "password_authentication" {
  description = "Allow password-based SSH logins. Keep false in every reachable environment."
  type        = bool
  default     = false
}

variable "permit_root_login" {
  description = "sshd PermitRootLogin value."
  type        = string
  default     = "prohibit-password"

  validation {
    condition     = contains(["yes", "no", "prohibit-password", "forced-commands-only"], var.permit_root_login)
    error_message = "permit_root_login must be one of \"yes\", \"no\", \"prohibit-password\" or \"forced-commands-only\"."
  }
}

variable "max_auth_tries" {
  description = "sshd MaxAuthTries. Each attempt is allowed 3 chances by default, which is generous for a brute-force defence."
  type        = number
  default     = 3
}

variable "login_grace_time" {
  description = "sshd LoginGraceTime in seconds: how long an unauthenticated connection may take to authenticate."
  type        = number
  default     = 30
}

variable "client_alive_interval" {
  description = "Seconds of silence before sshd sends a keepalive to the client."
  type        = number
  default     = 300
}

variable "client_alive_count_max" {
  description = "How many unanswered keepalives before the connection is dropped."
  type        = number
  default     = 2
}

variable "allow_tcp_forwarding" {
  description = "Allow SSH port forwarding. Disable unless a tunnel is genuinely required."
  type        = bool
  default     = false
}

variable "ssh_ciphers" {
  description = "Explicit sshd Ciphers list. Leave empty to keep the distribution default."
  type        = string
  default     = ""
}

variable "extra_sshd_directives" {
  description = "Additional sshd_config directives, one per line. Indentation is added automatically."
  type        = string
  default     = ""
}

variable "packages" {
  description = "Packages installed before hardening is applied."
  type        = list(string)
  default     = ["openssh-server", "fail2ban", "ca-certificates"]
}

variable "fail2ban_enabled" {
  description = "Enable the fail2ban SSH jail."
  type        = bool
  default     = true
}

variable "fail2ban_bantime" {
  description = "How long a banned IP stays banned."
  type        = string
  default     = "1h"
}

variable "fail2ban_findtime" {
  description = "Window over which failed attempts are counted."
  type        = string
  default     = "10m"
}

variable "fail2ban_maxretry" {
  description = "Failed attempts within findtime that trigger a ban."
  type        = number
  default     = 5
}

variable "fail2ban_ignoreip" {
  description = "Addresses exempt from bans. Add your own egress ranges here."
  type        = list(string)
  default     = ["127.0.0.1/8", "::1/128"]
}

variable "ssh_service_name" {
  description = "systemd unit to restart. Debian and Ubuntu use \"ssh\"; RHEL derivatives use \"sshd\"."
  type        = string
  default     = "ssh"
}