output "recovery_points" {
  description = "Map of logical name to the verified snapshot metadata."
  value       = local.recovery_points
}

output "at_risk" {
  description = "Recovery points already carrying a deprecation date, which must be replaced before it expires."
  value       = local.at_risk
}

output "objectives" {
  description = "Recovery point and recovery time objectives per recovery point."
  value = {
    for k, v in var.recovery_points : k => {
      rpo_minutes    = v.rpo_minutes
      rto_minutes    = v.rto_minutes
      target_role    = v.target_role
      primary_region = var.primary_region
    }
  }
}

output "runbook" {
  description = "Markdown runbook generated from the verified recovery points."
  value       = local.runbook
}