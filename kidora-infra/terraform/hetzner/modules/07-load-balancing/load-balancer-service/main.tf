# protocol decides how TLS is handled: "https" terminates TLS on the load balancer
# and needs certificates, "tcp" passes the encrypted stream through untouched.
# listen_port and destination_port are required for tcp and optional otherwise.
resource "hcloud_load_balancer_service" "this" {
  for_each = var.services

  load_balancer_id = each.value.load_balancer_id
  protocol         = each.value.protocol
  listen_port      = each.value.protocol == "tcp" ? each.value.listen_port : null
  destination_port = each.value.protocol == "tcp" ? each.value.destination_port : null
  proxyprotocol    = each.value.proxyprotocol

  http {
    sticky_sessions = each.value.sticky_sessions
    cookie_name     = each.value.cookie_name
    cookie_lifetime = each.value.cookie_lifetime
    redirect_http   = each.value.redirect_http
    timeout_idle    = each.value.timeout_idle
    certificates    = each.value.certificates
  }

  dynamic "health_check" {
    for_each = each.value.health_check == null ? [] : [each.value.health_check]

    content {
      protocol = health_check.value.protocol
      port     = health_check.value.port
      interval = health_check.value.interval
      timeout  = health_check.value.timeout
      retries  = health_check.value.retries

      dynamic "http" {
        for_each = health_check.value.protocol == "http" ? [health_check.value.http] : []

        content {
          domain       = http.value.domain
          path         = http.value.path
          response     = http.value.response
          tls          = http.value.tls
          status_codes = http.value.status_codes
        }
      }
    }
  }
}