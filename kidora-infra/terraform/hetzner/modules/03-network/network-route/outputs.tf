output "id" {
  description = "Map of logical name to the hcloud_network_route resource ID."
  value       = { for k, v in hcloud_network_route.this : k => v.id }
}

output "routes" {
  description = "Map of logical name to the destination and gateway pair that was installed."
  value       = { for k, v in hcloud_network_route.this : k => { destination = v.destination, gateway = v.gateway } }
}