output "domain" {
  description = "The DNS domain name"
  value       = vultr_dns_domain.domain.domain
}

output "domain_id" {
  description = "The DNS domain ID"
  value       = vultr_dns_domain.domain.id
}
