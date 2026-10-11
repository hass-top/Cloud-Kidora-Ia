output "id" {
  description = "Map of logical name to Hetzner firewall ID."
  value       = { for k, v in hcloud_firewall.this : k => v.id }
}

output "rule_count" {
  description = "Map of logical name to the number of rules installed."
  value       = { for k, v in hcloud_firewall.this : k => length(v.rule) }
}