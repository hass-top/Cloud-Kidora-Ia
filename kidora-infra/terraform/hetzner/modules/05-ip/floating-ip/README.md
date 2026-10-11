# floating-ip

Creates floating IPs, either bound to a server immediately or created unassigned for later assignment.

**Backing:** Resource: hcloud_floating_ip.

## Notes

Exactly one of server_id or home_location must be set. For load balancers use a Primary IP instead: a floating IP cannot be attached to a load balancer.

## Inputs

| Name | Description |
| --- | --- |
| `floating_ips` | Map of floating IPs to manage. Map key is the logical name used for wiring. |
| `labels` | Labels applied to every floating IP created by this module. |

## Outputs

- `id`

- `ip_address`

- `ip_network`

## Usage

````hcl
module "floating-ip" {
  source = "../../modules/05-ip/floating-ip"
}
````
