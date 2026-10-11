output "id" {
  description = "Map of logical name to Hetzner primary IP ID."
  value       = { for k, v in hcloud_primary_ip.this : k => v.id }
}

output "ip_address" {
  description = "Map of logical name to the allocated IP address."
  value       = { for k, v in hcloud_primary_ip.this : k => v.ip_address }
}

output "ipv4" {
  description = "Map of logical name to the ID of the IPv4 primary IP only, ready for hcloud_server.public_net.ipv4."
  value       = { for k, v in hcloud_primary_ip.this : k => v.id if v.type == "ipv4" }
}