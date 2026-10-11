# Two certificate sources are supported through one input map. Managed
# certificates are issued and renewed by Hetzner; uploaded certificates bring a
# key and chain the caller already holds. Both use create_before_destroy so a
# renewal swaps the new certificate in before the old one is removed.
#
# The map is intentionally NOT marked sensitive. A private key has to be sent to
# the API, so it is written to state in plaintext either way; the sensitive flag
# would only mask CLI output while breaking for_each, and would give false
# confidence that the key is protected. Protect the state backend instead.
resource "hcloud_managed_certificate" "managed" {
  for_each = { for k, v in var.certificates : k => v if v.type == "managed" }

  name         = each.value.name
  domain_names = each.value.domain_names
  labels       = merge(var.labels, each.value.labels)

  lifecycle {
    create_before_destroy = true
  }
}

resource "hcloud_uploaded_certificate" "uploaded" {
  for_each = { for k, v in var.certificates : k => v if v.type == "uploaded" }

  name        = each.value.name
  certificate = each.value.certificate
  private_key = each.value.private_key
  labels      = merge(var.labels, each.value.labels)

  lifecycle {
    create_before_destroy = true
  }
}

# Both resources are normalised to one shape before being combined, because merge()
# requires identical types and the two provider resources have different schemas.
locals {
  certificates = merge(
    { for k, v in hcloud_managed_certificate.managed : k => { id = v.id, not_valid_after = v.not_valid_after, domain_names = v.domain_names } },
    { for k, v in hcloud_uploaded_certificate.uploaded : k => { id = v.id, not_valid_after = v.not_valid_after, domain_names = v.domain_names } },
  )
}