resource "vultr_firewall_group" "main" {
  description = var.firewall_name
}


resource "vultr_firewall_rule" "rules" {

  count = length(var.rules)

  firewall_group_id = vultr_firewall_group.main.id

  protocol = var.rules[count.index].protocol
  port     = var.rules[count.index].port

  ip_type = var.rules[count.index].ip_type

  subnet = var.rules[count.index].subnet

  subnet_size = var.rules[count.index].subnet_size
}