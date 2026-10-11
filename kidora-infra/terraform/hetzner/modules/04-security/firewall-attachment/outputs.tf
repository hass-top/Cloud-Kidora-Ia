output "id" {
  description = "Map of logical name to the attachment ID, which equals the firewall ID."
  value       = { for k, v in hcloud_firewall_attachment.this : k => v.id }
}