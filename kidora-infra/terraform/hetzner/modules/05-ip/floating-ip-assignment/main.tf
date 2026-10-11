# Assignments are separated from floating IP creation so a single address can be
# moved between servers without recreating the address itself. Note this resource
# targets servers; Hetzner load balancers take a Primary IP rather than a Floating IP.
resource "hcloud_floating_ip_assignment" "this" {
  for_each = var.assignments

  floating_ip_id = each.value.floating_ip_id
  server_id      = each.value.server_id
}