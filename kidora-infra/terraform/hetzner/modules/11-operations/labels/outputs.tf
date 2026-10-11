output "labels" {
  description = "The label map to pass to the `labels` variable of any resource module."
  value       = local.labels
}

output "selectors" {
  description = "Map of label key to ready-made \"key=value\" selector string."
  value       = local.selectors
}

output "role_selector" {
  description = "Selector matching this role, or null when no role is set."
  value       = var.role == null ? null : "role=${var.role}"
}

output "environment_selector" {
  description = "Selector matching every resource in this environment."
  value       = "env=${var.environment}"
}