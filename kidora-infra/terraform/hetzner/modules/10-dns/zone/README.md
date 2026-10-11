# zone

Manages Hetzner authoritative DNS zones.

**Backing:** Resource: hcloud_zone.

## Notes

mode primary means Hetzner holds the records; secondary mirrors a primary you run elsewhere and requires primary_nameservers. `nameserver_map` renders the assigned nameservers as NS records for the registrar.

## Inputs

| Name | Description |
| --- | --- |
| `zones` | Map of DNS zones to manage. Map key is the logical name used for wiring. |
| `labels` | Labels applied to every zone created by this module. |

## Outputs

- `id`

- `name`

- `authoritative_nameservers`

- `nameserver_map`

## Usage

````hcl
module "zone" {
  source = "../../modules/10-dns/zone"
}
````
