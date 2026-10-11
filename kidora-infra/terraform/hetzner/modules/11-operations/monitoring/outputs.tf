output "targets" {
  description = "Map of logical name to the scrapeable target configuration."
  value       = local.scrapeable
}

output "target_list" {
  description = "Prometheus static target list, one address per entry."
  value       = sort([for t in values(local.scrapeable) : "${t.ip}:${t.port}"])
}

output "targets_by_role" {
  description = "Scrape target hostnames grouped by role, for dashboards that filter by role."
  value       = local.targets_by_role
}

output "missing_address" {
  description = "Targets marked as scrapeable but missing an address. A non-empty list means the server map and this module disagree."
  value       = local.missing_address
}

output "labels" {
  description = "Labels to attach to every scrape job for these targets."
  value = {
    environment = var.environment
    managed_by  = "terraform"
  }
}