output "id" {
  description = "Map of logical name to the service resource ID, formatted <load-balancer-id>__<listen-port>."
  value       = { for k, v in hcloud_load_balancer_service.this : k => v.id }
}