# Hardening is a cloud-init fragment, not a resource: the provider has no
# equivalent resource, and the content is byte-identical every apply, so the
# server's user_data never churns.
locals {
  user_data = templatefile("${path.module}/templates/ssh-hardening.yaml.tftpl", {
    packages                = var.packages
    password_authentication = var.password_authentication
    permit_root_login       = var.permit_root_login
    max_auth_tries          = var.max_auth_tries
    login_grace_time        = var.login_grace_time
    client_alive_interval   = var.client_alive_interval
    client_alive_count_max  = var.client_alive_count_max
    allow_tcp_forwarding    = var.allow_tcp_forwarding
    ssh_ciphers             = var.ssh_ciphers
    extra_sshd_directives   = var.extra_sshd_directives
    fail2ban_enabled        = var.fail2ban_enabled
    fail2ban_bantime        = var.fail2ban_bantime
    fail2ban_findtime       = var.fail2ban_findtime
    fail2ban_maxretry       = var.fail2ban_maxretry
    fail2ban_ignoreip       = var.fail2ban_ignoreip
    service_name            = var.ssh_service_name
  })
}