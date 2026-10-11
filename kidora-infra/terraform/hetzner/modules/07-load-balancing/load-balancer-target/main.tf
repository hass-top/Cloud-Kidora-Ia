# A label_selector target is the recommended form: membership follows the labels
# on the servers, so a replacement server joins the pool on the next apply
# without the target resource changing. Set use_private_ip so traffic stays on the
# Hetzner network and never crosses the public internet.
resource "hcloud_load_balancer_target" "this" {
  for_each = var.targets

  type             = each.value.type
  load_balancer_id = each.value.load_balancer_id
  server_id        = each.value.server_id
  label_selector   = each.value.label_selector
  ip               = each.value.ip
  use_private_ip   = each.value.use_private_ip
}