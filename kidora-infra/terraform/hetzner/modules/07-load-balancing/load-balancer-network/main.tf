resource "hcloud_load_balancer_network" "this" {
  for_each = var.attachments

  load_balancer_id        = each.value.load_balancer_id
  subnet_id               = each.value.subnet_id
  network_id              = each.value.network_id
  ip                      = each.value.ip
  enable_public_interface = each.value.enable_public_interface
}