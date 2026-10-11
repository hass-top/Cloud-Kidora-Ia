output "id" {
  description = "Map of logical name to Hetzner network ID."
  value       = { for k, v in hcloud_network.this : k => v.id }
}

output "ip_range" {
  description = "Map of logical name to the network CIDR."
  value       = { for k, v in hcloud_network.this : k => v.ip_range }
}