output "id" {
  description = "Map of logical name to the resolved image ID, ready for hcloud_server.image."
  value       = { for k, v in data.hcloud_image.this : k => v.id }
}

output "details" {
  description = "Map of logical name to image metadata, useful for deprecation alerts before a rebuild breaks."
  value = {
    for k, v in data.hcloud_image.this : k => {
      description           = v.description
      type                  = v.type
      architecture          = v.architecture
      deprecated            = v.deprecated
      deprecation_announced = v.deprecation_announced
      unavailable_after     = v.unavailable_after
      os                    = "${v.os_flavor} ${v.os_version}"
      created               = v.created
    }
  }
}

output "deprecating" {
  description = "Images that already carry a deprecation date. Rebuild onto these before the date and the server fails to create."
  value       = { for k, v in data.hcloud_image.this : k => v.deprecated if v.deprecated != null }
}