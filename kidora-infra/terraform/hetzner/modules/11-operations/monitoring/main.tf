# Handoff module, by design. The provider has no metric or exporter resource, so
# there is nothing here to create. What the module does do is produce the scrape
# target list that Prometheus needs, filtered to hosts that are actually
# reachable, and derived from the same server map that built the infrastructure.
# The monitoring stack itself stays in Ansible and Helm, where it already lives.
locals {
  scrapeable = {
    for k, t in var.targets : k => t
    if t.scrape && t.ip != null
  }

  targets_by_role = {
    for role in distinct([for t in values(local.scrapeable) : t.role]) :
    role => sort([for k, t in local.scrapeable : t.name if t.role == role])
  }

  # A host that is labelled as scrapeable but has no address is a provisioning
  # bug, and reporting it here is cheaper than debugging an empty target list.
  missing_address = [for k, t in var.targets : k if t.scrape && t.ip == null]
}