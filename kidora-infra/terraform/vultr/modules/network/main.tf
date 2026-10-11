resource "vultr_vpc" "main" {
  region      = var.region
  description = var.name
}
