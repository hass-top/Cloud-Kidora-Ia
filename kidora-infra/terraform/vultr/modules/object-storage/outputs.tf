output "storage_id" {
  description = "The ID of the object storage"
  value       = vultr_object_storage.storage.id
}

output "storage_label" {
  description = "The label of the object storage"
  value       = vultr_object_storage.storage.label
}

output "storage_endpoint" {
  description = "The endpoint URL of the object storage"
  value       = vultr_object_storage.storage.endpoint
}

output "access_key" {
  description = "The access key for the object storage"
  value       = vultr_object_storage.storage.access_key
  sensitive   = true
}

output "secret_key" {
  description = "The secret key for the object storage"
  value       = vultr_object_storage.storage.secret_key
  sensitive   = true
}
