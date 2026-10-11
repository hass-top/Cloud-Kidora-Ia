# Configuration, not a resource. Backups are the `backups` argument on
# hcloud_server, so there is no backup resource to wrap. This module validates the
# desired window and hands the on/off switch to 02-compute/server.
#
# The window itself cannot be applied by Terraform. In provider 1.69
# hcloud_server.backup_window is Computed and Deprecated, and hcloud_volume has no
# backup argument at all. Hetzner treats the window as a project-level setting set
# in the console, which a server inherits. So `window` here is a declared intent
# that is checked against the three windows Hetzner offers and reported in the plan
# output; it is not pushed to the API. The two `*_supported` outputs make that
# distinction visible rather than leaving it to be inferred from missing code.
locals {
  allowed_windows = ["00-06", "02-08", "22-02"]

  summary = {
    enabled           = var.enabled
    requested_window  = var.window
    window_applied    = false
    server_backups    = "declarative via the `backups` argument of 02-compute/server"
    window_management = "set the project backup window in the Hetzner console; provider 1.69 marks hcloud_server.backup_window as computed and deprecated"
    volume_backups    = "not declaratively manageable: hcloud_volume exposes no backup argument in provider 1.69"
  }
}