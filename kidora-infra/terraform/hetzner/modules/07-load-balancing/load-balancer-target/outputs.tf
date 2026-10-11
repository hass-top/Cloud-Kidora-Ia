output "id" {
  description = "Map of logical name to the target resource ID."
  value       = { for k, v in hcloud_load_balancer_target.this : k => v.id }
}