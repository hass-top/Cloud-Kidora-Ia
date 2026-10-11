output "id" {
  description = "Map of logical name to the assignment resource ID, equal to the floating IP ID."
  value       = { for k, v in hcloud_floating_ip_assignment.this : k => v.id }
}