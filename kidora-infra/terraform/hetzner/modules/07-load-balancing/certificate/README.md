# certificate

Obtains Hetzner-managed certificates, or uploads a certificate you already hold.

**Backing:** Resources: hcloud_managed_certificate and hcloud_uploaded_certificate.

## Notes

create_before_destroy prevents downtime on renewal. The certificates variable is deliberately not marked sensitive: an uploaded private key is written to state in plaintext either way, so protect the state backend rather than trusting masking.

## Inputs

| Name | Description |
| --- | --- |
| `certificates` | (see variables.tf) |
| `labels` | Labels applied to every certificate created by this module. |

## Outputs

- `id`

- `managed_ids`

- `expiry`

- `domain_names`

## Usage

````hcl
module "certificate" {
  source = "../../modules/07-load-balancing/certificate"
}
````
