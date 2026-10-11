output "backups" {
  description = "Value for the `backups` argument of 02-compute/server."
  value       = var.enabled
}

output "requested_window" {
  description = "The backup window this configuration asks for. Not applied by Terraform; compare it against the console."
  value       = var.window
}

output "backup_window_applied" {
  description = "Always false. Terraform cannot set the backup window in provider 1.69."
  value       = false
}

output "server_backups_supported" {
  description = "True: backups can be switched on and off for servers."
  value       = true
}

output "volume_backups_supported" {
  description = "Always false. hcloud_volume exposes no backup argument in provider 1.69."
  value       = false
}

output "summary" {
  description = "Backup configuration and the two provider limitations, for runbooks and audit output."
  value       = local.summary
}