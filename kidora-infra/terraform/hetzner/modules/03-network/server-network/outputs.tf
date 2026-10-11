output "id" {
  description = "Map of logical name to the hcloud_server_network resource ID."
  value       = { for k, v in hcloud_server_network.this : k => v.id }
}

output "mac_address" {
  description = "Map of logical name to the MAC address of the private interface."
  value       = { for k, v in hcloud_server_network.this : k => v.mac_address }
}