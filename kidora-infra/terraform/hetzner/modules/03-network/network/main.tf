resource "hcloud_network" "this" {
  for_each = var.networks

  name              = each.value.name
  ip_range          = each.value.ip_range
  labels            = merge(var.labels, each.value.labels)
  delete_protection = each.value.delete_protection

  expose_routes_to_vswitch = each.value.expose_routes_to_vswitch
}