output "health_check" {
  description = "Health check object, ready for the `health_check` variable of 07-load-balancing/load-balancer-service."
  value       = local.health_check
}