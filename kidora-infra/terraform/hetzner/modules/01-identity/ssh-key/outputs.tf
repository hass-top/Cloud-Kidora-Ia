output "id" {
  description = "Map of logical key name to Hetzner SSH key ID."
  value       = { for k, v in hcloud_ssh_key.this : k => v.id }
}

output "key_ids" {
  description = "List of Hetzner SSH key IDs, ready for hcloud_server.ssh_keys."
  value       = [for v in hcloud_ssh_key.this : v.id]
}

output "fingerprint" {
  description = "Map of logical key name to the fingerprint reported by Hetzner."
  value       = { for k, v in hcloud_ssh_key.this : k => v.fingerprint }
}