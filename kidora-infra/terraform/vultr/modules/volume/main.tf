resource "vultr_block_storage" "volume" {
  label    = var.name
  region   = var.region
  size     = var.size
  block_type = var.block_type

  lifecycle {
    ignore_changes = [instance_id]
  }
}

resource "vultr_block_storage_mount" "mount" {
  count = var.mount_path != null ? 1 : 0

  block_storage_id = vultr_block_storage.volume.id
  mount_path       = var.mount_path
}
