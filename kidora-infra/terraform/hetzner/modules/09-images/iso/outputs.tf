output "reference" {
  description = "Map of logical name to the ISO reference, ready for hcloud_server.iso."
  value       = { for k, v in local.isos : k => v.reference }
}

output "is_supported" {
  description = "Always false: the provider cannot validate an ISO reference before boot."
  value       = false
}