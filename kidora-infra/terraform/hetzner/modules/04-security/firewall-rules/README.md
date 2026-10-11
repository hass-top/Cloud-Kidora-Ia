# firewall-rules

Normalises and audits firewall rules before they are applied.

**Backing:** No provider resource: rules are inline blocks on hcloud_firewall, so this module is a policy layer.

## Notes

Reports `ssh_exposed_to_world`, which flags an inbound SSH rule accepting any address. That is the most common way a host gets brute-forced and it is worth seeing in plan output rather than in a config file.

## Inputs

| Name | Description |
| --- | --- |
| `rules` | Firewall rules to normalise. Map key is the logical name used for wiring and in diagnostics. |

## Outputs

- `rules`

- `ssh_exposed_to_world`

- `world_open_ports`

## Usage

````hcl
module "firewall-rules" {
  source = "../../modules/04-security/firewall-rules"
}
````
