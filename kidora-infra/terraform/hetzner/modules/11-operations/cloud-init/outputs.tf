output "user_data" {
  description = "Rendered cloud-config, ready for the `user_data` argument of 02-compute/server."
  value       = local.user_data
}

output "fragment_count" {
  description = "Number of cloud-init documents in the rendered output."
  value       = length(local.fragments)
}