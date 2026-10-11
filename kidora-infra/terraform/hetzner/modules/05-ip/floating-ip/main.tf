# A Floating IP is created unassigned (home_location set) or already bound to a
# server (server_id set). Exactly one of the two must be provided, which the
# variable validation enforces.
resource "hcloud_floating_ip" "this" {
  for_each = var.floating_ips

  type              = each.value.type
  name              = each.value.name
  server_id         = each.value.server_id
  home_location     = each.value.home_location
  description       = each.value.description
  labels            = merge(var.labels, each.value.labels)
  delete_protection = each.value.delete_protection
}