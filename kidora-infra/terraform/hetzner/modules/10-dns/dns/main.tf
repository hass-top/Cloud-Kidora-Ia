# There is no hcloud_dns_record resource. DNS records live in hcloud_zone_rrset,
# which groups every record of one name and type into a single set. The map key
# therefore has to distinguish name and type pairs, for example "app" and "app-txt".
#
# Two provider behaviours matter here: TXT values must be quoted strings of at
# most 255 characters, and the SOA record is created and maintained by the API, so
# do not declare it.
resource "hcloud_zone_rrset" "this" {
  for_each = var.recordsets

  zone              = var.zone
  name              = each.value.name
  type              = each.value.type
  ttl               = each.value.ttl
  labels            = merge(var.labels, each.value.labels)
  change_protection = each.value.change_protection

  records = each.value.records
}