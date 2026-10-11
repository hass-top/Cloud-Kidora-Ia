output "id" {
  description = "Map of logical name to the attachment resource ID."
  value       = { for k, v in hcloud_load_balancer_network.this : k => v.id }
}