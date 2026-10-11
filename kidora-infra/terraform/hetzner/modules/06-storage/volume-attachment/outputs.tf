output "id" {
  description = "Map of logical name to the attachment ID, which equals the volume ID."
  value       = { for k, v in hcloud_volume_attachment.this : k => v.id }
}