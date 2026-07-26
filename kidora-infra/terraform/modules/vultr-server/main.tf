resource "vultr_instance" "server" {

  plan   = var.plan
  region = var.region
  os_id  = var.os_id

  label = var.name
  firewall_group_id = var.firewall_id
  ssh_key_ids       = var.ssh_key_id != null ? [var.ssh_key_id] : []
  vpc_id            = var.vpc_id
}
