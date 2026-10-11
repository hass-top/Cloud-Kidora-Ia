output "id" {
  description = "Map of logical name to the record set ID."
  value       = { for k, v in hcloud_zone_rrset.this : k => v.id }
}

output "a_records" {
  description = "Map of logical name to the A record values, for cross-checking against a load balancer address."
  value = {
    for k, v in hcloud_zone_rrset.this : k => [for r in v.records : r.value]
    if v.type == "A"
  }
}