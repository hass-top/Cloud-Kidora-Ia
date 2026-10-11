output "app_ip" {
  value = module.prod_servers["app"].ip_address
}

output "database_ip" {
  value = module.prod_servers["database"].ip_address
}

output "monitoring_ip" {
  value = module.prod_servers["monitoring"].ip_address
}