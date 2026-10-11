output "id" {
  description = "Map of logical name to Hetzner network subnet ID."
  value       = { for k, v in hcloud_network_subnet.this : k => v.id }
}

output "ip_range" {
  description = "Map of logical name to the subnet CIDR."
  value       = { for k, v in hcloud_network_subnet.this : k => v.ip_range }
}