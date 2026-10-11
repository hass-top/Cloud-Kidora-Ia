# load-balancer-network

Attaches a load balancer to a private network.

**Backing:** Resource: hcloud_load_balancer_network.

## Notes

Set enable_public_interface to false to close the load balancer to the public internet and serve it only over the private network.

## Inputs

| Name | Description |
| --- | --- |
| `attachments` | Map of load balancer to network attachments. Map key is the logical name used for wiring. |

## Outputs

- `id`

## Usage

````hcl
module "load-balancer-network" {
  source = "../../modules/07-load-balancing/load-balancer-network"
}
````
