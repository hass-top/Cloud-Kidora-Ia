# dns

Manages DNS record sets inside a Hetzner zone.

**Backing:** Resource: hcloud_zone_rrset.

## Notes

There is no hcloud_dns_record: records are grouped by name and type into a set, so map keys must distinguish them, for example "app" and "app-txt". Two provider behaviours matter: TXT values must be quoted strings of at most 255 characters (the provider exposes a txt_record() helper function for this), and the SOA record is created and incremented by the API, so declaring one is rejected by validation.

## Inputs

| Name | Description |
| --- | --- |
| `zone` | Name or ID of the Hetzner zone these records belong to. |
| `recordsets` | Map of record sets. The map key must be unique per name and type, for example "app", "app-txt". |
| `labels` | Labels applied to every record set created by this module. |

## Outputs

- `id`

- `a_records`

## Usage

````hcl
module "dns" {
  source = "../../modules/10-dns/dns"
}
````
