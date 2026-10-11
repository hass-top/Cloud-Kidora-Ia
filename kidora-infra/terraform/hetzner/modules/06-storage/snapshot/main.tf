# This is the canonical snapshot module. 09-images/snapshot was removed so that
# one resource type is managed in one place.
#
# hcloud_snapshot takes a server_id only: it cannot snapshot a volume, and it
# exposes no `name` argument. The snapshot is identified by its numeric image ID
# and carries only a description and labels. Both limits are real provider gaps,
# recorded in the module README.
resource "hcloud_snapshot" "this" {
  for_each = var.snapshots

  server_id   = each.value.server_id
  description = each.value.description
  labels      = merge(var.labels, each.value.labels)
}