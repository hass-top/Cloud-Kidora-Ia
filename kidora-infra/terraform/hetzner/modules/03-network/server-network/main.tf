# alias_ips is always set, defaulting to an empty set. The provider detaches and
# reattaches the network on every apply when alias_ips is null (issue #650), so an
# explicit empty set keeps the attachment stable across plans.
resource "hcloud_server_network" "this" {
  for_each = var.attachments

  server_id  = each.value.server_id
  subnet_id  = each.value.subnet_id
  network_id = each.value.network_id
  ip         = each.value.ip
  alias_ips  = each.value.alias_ips
}