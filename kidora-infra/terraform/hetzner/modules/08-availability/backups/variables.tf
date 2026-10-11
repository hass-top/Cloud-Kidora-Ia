variable "enabled" {
  description = "Enable automatic server backups. Backups are billed per server and are not included in the instance price."
  type        = bool
  default     = true
}

variable "window" {
  description = "Requested backup window in UTC. Hetzner offers exactly three: 00-06, 02-08 and 22-02. Declared intent only; see the module README."
  type        = string
  default     = "22-02"

  validation {
    condition     = contains(["00-06", "02-08", "22-02"], var.window)
    error_message = "Hetzner offers only three backup windows: \"00-06\", \"02-08\" and \"22-02\"."
  }
}

variable "assert_window_applied" {
  description = "Set to false only when the console window is known to match `window`. The mismatch is reported either way, so this guards against assuming the setting took effect."
  type        = bool
  default     = false
}