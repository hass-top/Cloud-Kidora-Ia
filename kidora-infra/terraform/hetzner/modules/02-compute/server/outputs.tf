output "id" {
  description = "Map of logical name to Hetzner server ID."
  value       = { for k, v in hcloud_server.this : k => v.id }
}

output "ipv4_address" {
  description = "Map of logical name to the public IPv4 address."
  value       = { for k, v in hcloud_server.this : k => v.ipv4_address }
}

output "ipv6_address" {
  description = "Map of logical name to the public IPv6 address."
  value       = { for k, v in hcloud_server.this : k => v.ipv6_address }
}

output "ipv6_network" {
  description = "Map of logical name to the routed IPv6 network."
  value       = { for k, v in hcloud_server.this : k => v.ipv6_network }
}

output "private_ips" {
  description = "Map of logical name to the private addresses configured on the network block."
  value       = { for k, v in hcloud_server.this : k => [for n in v.network : n.ip] }
}

output "server_ids" {
  description = "List of server IDs, useful for downstream for_each consumers."
  value       = [for v in hcloud_server.this : v.id]
}

output "backup_window" {
  description = "Map of logical name to the backup window the server actually inherited. Read-only: Terraform cannot set this, so it is useful for verifying the console setting took effect."
  value       = { for k, v in hcloud_server.this : k => v.backup_window }
}

output "backups_enabled" {
  description = "Map of logical name to whether automatic backups are active."
  value       = { for k, v in hcloud_server.this : k => v.backups }
}