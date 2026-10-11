# location pins the load balancer to a single location, network_zone spreads it
# across every location in that zone. Exactly one must be set: the provider
# requires one of the two.
resource "hcloud_load_balancer" "this" {
  for_each = var.load_balancers

  name               = each.value.name
  load_balancer_type = each.value.load_balancer_type
  location           = each.value.network_zone == null ? each.value.location : null
  network_zone       = each.value.network_zone
  labels             = merge(var.labels, each.value.labels)
  delete_protection  = each.value.delete_protection

  algorithm {
    type = each.value.algorithm
  }
}