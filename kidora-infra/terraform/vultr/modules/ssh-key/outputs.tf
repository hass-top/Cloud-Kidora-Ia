output "ssh_key_id" {
  description = "The ID of the SSH key"
  value       = vultr_ssh_key.key.id
}

output "ssh_key_name" {
  description = "The name of the SSH key"
  value       = vultr_ssh_key.key.name
}
