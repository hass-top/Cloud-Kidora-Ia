output "rules" {
  description = "Normalised rule list, ready to pass to the `rules` variable of the 04-security/firewall module."
  value       = local.rules
}

output "ssh_exposed_to_world" {
  description = "True when an inbound SSH rule accepts traffic from any address. Should be false outside preprod."
  value       = local.ssh_exposed_to_world
}

output "world_open_ports" {
  description = "Sorted list of TCP and UDP ports reachable from any address, for review during plan."
  value       = local.world_open_tcp_ports
}