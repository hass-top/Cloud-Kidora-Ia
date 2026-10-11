resource "vultr_load_balancer" "main" {

  region = var.region

  label = var.name

  balancing_algorithm = "roundrobin"

  forwarding_rules {
    frontend_protocol = "https"
    frontend_port     = 443

    backend_protocol = "http"
    backend_port     = 80
  }

  health_check {
    protocol = "http"
    port     = 80
    path     = "/"
  }

}