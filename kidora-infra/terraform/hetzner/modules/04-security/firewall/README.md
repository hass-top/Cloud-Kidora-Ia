# firewall

Creates firewalls from normalised rule sets and optionally attaches them.

**Backing:** Resource: hcloud_firewall.

## Notes

Rules are inline blocks: there is no hcloud_firewall_rules resource. Feed the `rules` variable with the output of 04-security/firewall-rules.

## Inputs

| Name | Description |
| --- | --- |
| `firewalls` | Map of firewalls to manage. Map key is the logical name used for wiring. |
| `labels` | Labels applied to every firewall created by this module. |

## Outputs

- `id`

- `rule_count`

## Usage

````hcl
module "firewall" {
  source = "../../modules/04-security/firewall"
}
````
