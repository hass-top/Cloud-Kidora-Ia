output "volume_id" {
  description = "The ID of the block storage volume"
  value       = vultr_block_storage.volume.id
}

output "volume_label" {
  description = "The label of the block storage volume"
  value       = vultr_block_storage.volume.label
}

output "mount_path" {
  description = "The mount path of the volume (if configured)"
  value       = var.mount_path
}
