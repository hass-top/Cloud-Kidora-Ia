output "app_ip" {
  value = module.preprod_servers["app"].ip_address
}

output "database_ip" {
  value = module.preprod_servers["database"].ip_address
}

output "monitoring_ip" {
  value = module.preprod_servers["monitoring"].ip_address
}