# There is no hcloud_load_balancer_health_check resource. A health check is an
# inline block on hcloud_load_balancer_service, which means a health check cannot
# be managed or reused independently. This module is the standalone expression of
# one, and 07-load-balancing/load-balancer-service spreads its output into the
# inline block.
locals {
  # The provider documents port as required only for tcp checks; an http check
  # probes the port carried by the service instead.
  health_check = {
    protocol = var.protocol
    port     = var.protocol == "tcp" ? var.port : null
    interval = var.interval
    timeout  = var.timeout
    retries  = var.retries
    http = {
      domain       = var.http.domain
      path         = var.http.path
      response     = var.http.response
      tls          = var.http.tls
      status_codes = var.http.status_codes
    }
  }
}