output "id" {
  description = "Map of logical name to the reverse DNS entry ID."
  value       = { for k, v in hcloud_rdns.this : k => v.id }
}