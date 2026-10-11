resource "hcloud_network_route" "this" {
  for_each = var.routes

  network_id  = each.value.network_id
  destination = each.value.destination
  gateway     = each.value.gateway
}