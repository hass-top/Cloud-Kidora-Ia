output "id" {
  description = "Map of logical name to the certificate ID, whatever its type. Feed to the `certificates` argument of 07-load-balancing/load-balancer-service."
  value       = { for k, v in local.certificates : k => v.id }
}

output "managed_ids" {
  description = "IDs of the Hetzner-managed certificates only."
  value       = { for k, v in hcloud_managed_certificate.managed : k => v.id }
}

output "expiry" {
  description = "Map of logical name to the certificate notAfter timestamp, for expiry monitoring."
  value       = { for k, v in local.certificates : k => v.not_valid_after }
}

output "domain_names" {
  description = "Map of logical name to the domains each certificate covers."
  value       = { for k, v in local.certificates : k => v.domain_names }
}