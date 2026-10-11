# The single source of truth for the label scheme. Everything else consumes these
# outputs rather than inventing its own keys, so a firewall label selector and a
# load balancer target selector can never drift apart.
locals {
  base = merge(
    {
      project    = var.project
      env        = var.environment
      role       = var.role
      managed_by = "terraform"
    },
    var.extra,
  )
}

locals {
  labels = var.role == null ? local.base : local.base

  # A selector is what hcloud_firewall.apply_to and hcloud_load_balancer_target
  # consume. It is emitted for the common case of selecting one role, and for all
  # keys otherwise so a selector can be built for any subset.
  selectors = merge(
    { for k, v in local.labels : k => "${k}=${v}" },
    var.extra_selectors,
  )
}