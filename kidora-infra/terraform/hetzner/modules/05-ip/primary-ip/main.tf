# A Primary IP is the address a server or load balancer holds for its whole
# lifetime. Assigning a pre-created Primary IP into hcloud_server.public_net.ipv4
# keeps the public address stable across a server replacement, which a Floating
# IP does not guarantee during the recreate window.
resource "hcloud_primary_ip" "this" {
  for_each = var.primary_ips

  name              = each.value.name
  type              = each.value.type
  location          = each.value.location
  assignee_type     = each.value.assignee_type
  assignee_id       = each.value.assignee_id
  auto_delete       = each.value.auto_delete
  labels            = merge(var.labels, each.value.labels)
  delete_protection = each.value.delete_protection
}