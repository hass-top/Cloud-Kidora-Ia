# network

Creates private networks (VPCs).

**Backing:** Resource: hcloud_network.

## Notes

ip_range must be an RFC1918 range and must span every subnet and route destination. Provider 1.69 exposes `expose_routes_to_vswitch`, not the older vpc/vpn flags.

## Inputs

| Name | Description |
| --- | --- |
| `networks` | Map of private networks to manage. Map key is the logical name used for wiring. |
| `labels` | Labels applied to every network created by this module. |

## Outputs

- `id`

- `ip_range`

## Usage

````hcl
module "network" {
  source = "../../modules/03-network/network"
}
````
