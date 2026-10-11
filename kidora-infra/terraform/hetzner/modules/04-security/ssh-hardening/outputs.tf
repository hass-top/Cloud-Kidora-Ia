output "user_data" {
  description = "Cloud-init fragment. Pass to hcloud_server.user_data, either directly or via 11-operations/cloud-init."
  value       = local.user_data
}

output "summary" {
  description = "Human-readable description of the hardening applied, for runbooks and audit output."
  value = {
    password_authentication = var.password_authentication
    permit_root_login       = var.permit_root_login
    allow_tcp_forwarding    = var.allow_tcp_forwarding
    max_auth_tries          = var.max_auth_tries
    fail2ban_enabled        = var.fail2ban_enabled
    packages                = var.packages
  }
}