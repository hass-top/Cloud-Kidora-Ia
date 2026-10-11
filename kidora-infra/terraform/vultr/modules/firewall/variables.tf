variable "firewall_name" {
  type = string
}

variable "rules" {
  type = list(object({
    protocol    = string
    port        = string
    ip_type     = string
    subnet      = string
    subnet_size = number
  }))
}