resource "vultr_ssh_key" "key" {
  name      = var.key_name
  ssh_key   = var.public_key
}
