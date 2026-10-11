# Renders a cloud-config document. Fragments supplied by other modules, such as
# 04-security/ssh-hardening, are appended as additional cloud-init documents
# separated by "---", which cloud-init processes in order. The rendered output is
# stable for stable inputs, so a server's user_data never changes between plans
# and Terraform does not see spurious diffs.
locals {
  base = templatefile("${path.module}/templates/base.yaml.tftpl", {
    timezone            = var.timezone
    hostname            = var.hostname
    manage_etc_hosts    = var.manage_etc_hosts
    packages            = var.packages
    user_name           = var.user_name
    ssh_authorized_keys = var.ssh_authorized_keys
    environment         = var.environment
    project             = var.project
    node_exporter       = var.node_exporter
  })

  fragments = compact(concat([local.base], var.additional_user_data))

  user_data = join("\n---\n", local.fragments)
}