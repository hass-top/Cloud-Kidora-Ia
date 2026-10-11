resource "vultr_reserved_ip" "this" {
  region      = var.region
  ip_type     = var.ip_type
  label       = var.label
  instance_id = var.instance_id
}