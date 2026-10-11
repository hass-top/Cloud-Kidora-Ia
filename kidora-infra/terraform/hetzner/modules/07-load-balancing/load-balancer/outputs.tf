output "id" {
  description = "Map of logical name to Hetzner load balancer ID."
  value       = { for k, v in hcloud_load_balancer.this : k => v.id }
}

output "ipv4" {
  description = "Map of logical name to the public IPv4 address assigned to the load balancer."
  value       = { for k, v in hcloud_load_balancer.this : k => v.ipv4 }
}

output "ipv6" {
  description = "Map of logical name to the public IPv6 address assigned to the load balancer."
  value       = { for k, v in hcloud_load_balancer.this : k => v.ipv6 }
}

output "private_ip" {
  description = "Map of logical name to the address on the first attached private network, once 07-load-balancing/load-balancer-network has run."
  value       = { for k, v in hcloud_load_balancer.this : k => v.network_ip }
}