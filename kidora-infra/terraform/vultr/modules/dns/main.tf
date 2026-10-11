resource "vultr_dns_domain" "domain" {
  domain = var.domain
}

resource "vultr_dns_record" "records" {
  for_each = { for rec in var.records : rec.name => rec }

  domain = vultr_dns_domain.domain.domain
  type   = each.value.type
  name   = each.value.name
  data   = each.value.data
  ttl = lookup(each.value, "ttl", 300)
  priority = lookup(each.value, "priority", null)
}
