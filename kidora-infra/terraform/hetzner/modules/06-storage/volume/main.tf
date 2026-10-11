# hcloud_volume accepts server_id or location, never both. Passing location only
# and attaching later with 06-storage/volume-attachment is the pattern that scales
# to several volumes per server, so server_id is suppressed whenever it is null.
resource "hcloud_volume" "this" {
  for_each = var.volumes

  name              = each.value.name
  size              = each.value.size
  location          = each.value.server_id == null ? each.value.location : null
  server_id         = each.value.server_id
  automount         = each.value.automount
  format            = each.value.format
  labels            = merge(var.labels, each.value.labels)
  delete_protection = each.value.delete_protection
}