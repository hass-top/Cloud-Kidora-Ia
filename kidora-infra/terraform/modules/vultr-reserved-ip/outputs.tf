output "reserved_ip_address" {
  description = "The reserved IP address"
  value       = vultr_reserved_ip.this.address
}

output "reserved_ip_id" {
  description = "The ID of the reserved IP"
  value       = vultr_reserved_ip.this.id
}

output "attached" {
  description = "Whether the reserved IP is attached to an instance"
  value       = var.instance_id != null
}