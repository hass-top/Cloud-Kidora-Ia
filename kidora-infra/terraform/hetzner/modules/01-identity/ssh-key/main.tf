resource "hcloud_ssh_key" "this" {
  for_each = var.keys

  name       = each.value.name
  public_key = trimspace(each.value.public_key)
  labels     = merge(var.labels, each.value.labels)
}