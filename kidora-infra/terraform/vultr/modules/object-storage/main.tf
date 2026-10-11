resource "vultr_object_storage" "storage" {
  label    = var.name
  region   = var.region
  cluster  = var.cluster
  tier     = var.tier
}
