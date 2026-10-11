# There is no hcloud_firewall_rules resource: firewall rules are inline `rule`
# blocks on hcloud_firewall. This module is therefore a schema and policy layer
# rather than a resource wrapper. It normalises rules, fills in a description when
# none is given, and computes the audit signals that an inline block cannot.

locals {
  rules = [
    for r in var.rules : {
      direction       = r.direction
      protocol        = r.protocol
      port            = r.port
      source_ips      = r.direction == "in" ? r.source_ips : []
      destination_ips = r.direction == "out" ? r.destination_ips : []
      description     = r.description != null ? r.description : "${r.direction == "in" ? "inbound" : "outbound"} ${r.protocol} ${r.port}"
    }
  ]

  # Rules that can admit an SSH session. "any", a bare port, a port list, and a
  # range such as "22-80" are all matched.
  ssh_rules = [
    for r in local.rules : r
    if r.direction == "in" && r.protocol == "tcp" && (r.port == "any" || can(regex("(^|,)22(-|,|$)", r.port)))
  ]

  # An SSH rule reachable from every address is the most common way a host gets
  # brute-forced, so it is reported explicitly instead of being buried in config.
  ssh_exposed_to_world = anytrue([
    for r in local.ssh_rules : contains(r.source_ips, "0.0.0.0/0") || contains(r.source_ips, "::/0")
  ])

  inbound = [for r in local.rules : r if r.direction == "in"]

  world_open_tcp_ports = sort(distinct([
    for r in local.inbound : r.port
    if contains(["tcp", "udp"], r.protocol)
    && (contains(r.source_ips, "0.0.0.0/0") || contains(r.source_ips, "::/0"))
  ]))
}