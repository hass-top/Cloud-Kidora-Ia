# hcloud_zone is Hetzner's own authoritative DNS. A "primary" zone means Hetzner
# holds the records; a "secondary" zone mirrors a primary you run elsewhere and
# requires primary_nameservers. Nameservers are only returned after the zone
# exists, which is why authoritative_nameservers is an output rather than an input.
resource "hcloud_zone" "this" {
  for_each = var.zones

  name                = each.value.name
  mode                = each.value.mode
  ttl                 = each.value.ttl
  primary_nameservers = each.value.primary_nameservers
  labels              = merge(var.labels, each.value.labels)
  delete_protection   = each.value.delete_protection
}