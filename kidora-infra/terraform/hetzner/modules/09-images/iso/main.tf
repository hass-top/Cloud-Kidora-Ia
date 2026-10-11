# PASSTHROUGH, BY DESIGN. The provider has no hcloud_iso data source, so there is
# nothing to look an ISO up with. hcloud_server.iso accepts an ISO name or ID as a
# plain string, so this module cannot resolve anything; it validates the reference
# and passes it through unchanged, which keeps the server definition readable and
# gives one place to document the caveat.
locals {
  isos = {
    for k, v in var.isos : k => {
      reference   = v.reference
      description = v.description
      mount_point = v.mount_point
    }
  }
}