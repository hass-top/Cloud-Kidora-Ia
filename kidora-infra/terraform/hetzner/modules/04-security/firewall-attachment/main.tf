# Hetzner allows only ONE attachment resource per firewall, and everything that
# should be protected by that firewall must be listed on it. Prefer a label
# selector over explicit server IDs: it keeps membership declarative and means a
# newly added server is protected without a second apply.
resource "hcloud_firewall_attachment" "this" {
  for_each = var.attachments

  firewall_id     = each.value.firewall_id
  server_ids      = each.value.server_ids
  label_selectors = each.value.label_selectors
}