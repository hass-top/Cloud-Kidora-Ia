output "id" {
  description = "Map of logical name to Hetzner zone ID."
  value       = { for k, v in hcloud_zone.this : k => v.id }
}

output "name" {
  description = "Map of logical name to the zone name."
  value       = { for k, v in hcloud_zone.this : k => v.name }
}

output "authoritative_nameservers" {
  description = "Map of logical name to the Hetzner nameservers assigned to the zone. Point the domain registrar at these."
  value       = { for k, v in hcloud_zone.this : k => v.authoritative_nameservers.assigned }
}

output "nameserver_map" {
  description = "Authoritative nameservers rendered as NS records, ready to apply at the registrar."
  value = {
    for k, v in hcloud_zone.this : k => [
      for ns in v.authoritative_nameservers.assigned : {
        name  = "@"
        type  = "NS"
        value = ns
      }
    ]
  }
}