output "id" {
  description = "Map of logical name to Hetzner floating IP ID."
  value       = { for k, v in hcloud_floating_ip.this : k => v.id }
}

output "ip_address" {
  description = "Map of logical name to the floating IP address."
  value       = { for k, v in hcloud_floating_ip.this : k => v.ip_address }
}

output "ip_network" {
  description = "Map of logical name to the IPv6 subnet, present only for IPv6 floating IPs."
  value       = { for k, v in hcloud_floating_ip.this : k => v.ip_network if v.type == "ipv6" }
}