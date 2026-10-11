# Firewall attachment happens through firewall_ids, not through
# hcloud_firewall_attachment, so the rules are already in place on first boot.
# There is no hcloud_rescue resource in the provider: rescue mode is an API-only
# action and is documented in the module README instead of being modelled here.
resource "hcloud_server" "this" {
  for_each = var.servers

  name        = each.value.name
  server_type = each.value.server_type
  location    = each.value.location
  image       = each.value.image
  iso         = each.value.iso

  ssh_keys     = each.value.ssh_keys
  firewall_ids = each.value.firewall_ids
  labels       = merge(var.labels, each.value.labels)

  # Only the on/off switch is declaratively manageable. hcloud_server.backup_window
  # is Computed and Deprecated in provider 1.69, so setting it is rejected; the
  # window is a project-level setting chosen in the Hetzner console and inherited
  # by the server. See 08-availability/backups.
  backups = each.value.backups

  placement_group_id       = each.value.placement_group_id
  delete_protection        = each.value.delete_protection
  rebuild_protection       = each.value.rebuild_protection
  shutdown_before_deletion = each.value.shutdown_before_deletion
  keep_disk                = each.value.keep_disk

  user_data = each.value.user_data

  public_net {
    ipv4_enabled = each.value.ipv4_enabled
    ipv6_enabled = each.value.ipv6_enabled
    ipv4         = each.value.primary_ipv4_id
  }

  dynamic "network" {
    for_each = each.value.networks

    content {
      subnet_id = network.value.subnet_id
      ip        = network.value.ip
      alias_ips = network.value.alias_ips
    }
  }
}