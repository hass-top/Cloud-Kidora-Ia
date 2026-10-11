resource "hcloud_firewall" "this" {
  for_each = var.firewalls

  name   = each.value.name
  labels = merge(var.labels, each.value.labels)

  dynamic "rule" {
    for_each = each.value.rules

    content {
      direction       = rule.value.direction
      protocol        = rule.value.protocol
      port            = rule.value.port
      source_ips      = rule.value.source_ips
      destination_ips = rule.value.destination_ips
      description     = rule.value.description
    }
  }

  # apply_to is a list of blocks in the schema, so it is emitted at most once.
  # Leaving apply_to null keeps the firewall unattached, which is the safe
  # default: an unattached firewall protects nothing, but it also cannot lock
  # you out of a running server.
  dynamic "apply_to" {
    for_each = each.value.apply_to == null ? [] : [each.value.apply_to]

    content {
      label_selector = apply_to.value.label_selector
      server         = apply_to.value.server_id
    }
  }
}