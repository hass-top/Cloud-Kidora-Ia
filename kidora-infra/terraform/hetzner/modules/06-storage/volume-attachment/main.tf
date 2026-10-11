# Attachments are separate from volumes so several volumes can be attached to one
# server. The provider docs are explicit: use location on the volume plus this
# resource when attaching more than one volume to a server.
resource "hcloud_volume_attachment" "this" {
  for_each = var.attachments

  volume_id = each.value.volume_id
  server_id = each.value.server_id
  automount = each.value.automount
}