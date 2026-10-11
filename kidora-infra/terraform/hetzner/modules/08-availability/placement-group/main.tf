# Placement groups live in 08-availability rather than 02-compute because spread is
# an availability property. This is the canonical location; 02-compute/placement-group
# was removed to avoid two modules managing the same resource type.
resource "hcloud_placement_group" "this" {
  for_each = var.placement_groups

  name   = each.value.name
  type   = var.type
  labels = merge(var.labels, each.value.labels)
}