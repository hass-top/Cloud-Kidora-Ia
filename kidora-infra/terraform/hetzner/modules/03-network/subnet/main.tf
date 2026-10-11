resource "hcloud_network_subnet" "this" {
  for_each = var.subnets

  network_id   = each.value.network_id
  type         = each.value.type
  network_zone = each.value.network_zone
  ip_range     = each.value.ip_range
  vswitch_id   = each.value.vswitch_id
}