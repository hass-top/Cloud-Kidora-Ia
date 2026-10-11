# Reverse DNS entries make addresses self-describing, which matters for mail
# deliverability and for anyone reading logs. Exactly one resource ID is required
# per entry: the provider keys the entry by resource and address.
resource "hcloud_rdns" "this" {
  for_each = var.entries

  server_id        = each.value.server_id
  primary_ip_id    = each.value.primary_ip_id
  floating_ip_id   = each.value.floating_ip_id
  load_balancer_id = each.value.load_balancer_id
  ip_address       = each.value.ip_address
  dns_ptr          = each.value.dns_ptr
}