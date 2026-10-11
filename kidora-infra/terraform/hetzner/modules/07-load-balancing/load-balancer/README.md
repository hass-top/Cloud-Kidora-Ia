# load-balancer

Creates load balancers.

**Backing:** Resource: hcloud_load_balancer.

## Notes

Exactly one of location (pinned to one location) or network_zone (spread across the zone).

## Inputs

| Name | Description |
| --- | --- |
| `load_balancers` | Map of load balancers to manage. Map key is the logical name used for wiring. |
| `labels` | Labels applied to every load balancer created by this module. |

## Outputs

- `id`

- `ipv4`

- `ipv6`

- `private_ip`

## Usage

````hcl
module "load-balancer" {
  source = "../../modules/07-load-balancing/load-balancer"
}
````
