output "id" {
  description = "Map of logical name to Hetzner placement group ID."
  value       = { for k, v in hcloud_placement_group.this : k => v.id }
}

output "name" {
  description = "Map of logical name to the placement group name."
  value       = { for k, v in hcloud_placement_group.this : k => v.name }
}