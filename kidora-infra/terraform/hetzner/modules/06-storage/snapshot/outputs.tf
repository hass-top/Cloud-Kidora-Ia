output "id" {
  description = "Map of logical name to the snapshot image ID, usable as hcloud_server.image to rebuild from it."
  value       = { for k, v in hcloud_snapshot.this : k => v.id }
}

output "description" {
  description = "Map of logical name to the snapshot description."
  value       = { for k, v in hcloud_snapshot.this : k => v.description }
}