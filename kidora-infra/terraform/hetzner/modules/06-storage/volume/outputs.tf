output "id" {
  description = "Map of logical name to Hetzner volume ID."
  value       = { for k, v in hcloud_volume.this : k => v.id }
}

output "linux_device" {
  description = "Map of logical name to the device path on the filesystem, for fstab entries."
  value       = { for k, v in hcloud_volume.this : k => v.linux_device }
}

output "location" {
  description = "Map of logical name to the location the volume lives in."
  value       = { for k, v in hcloud_volume.this : k => v.location }
}