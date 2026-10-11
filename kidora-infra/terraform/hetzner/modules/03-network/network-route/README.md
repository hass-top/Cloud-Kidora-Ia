# network-route

Adds routes to a private network, for example to reach another network or a VPN.

**Backing:** Resource: hcloud_network_route.

## Notes

The destination must be a subnet of the network ip_range. 172.31.1.1 is reserved by Hetzner for the public interface gateway and is rejected by validation.

## Inputs

| Name | Description |
| --- | --- |
| `routes` | Map of routes to add to networks. Map key is the logical name used for wiring. |

## Outputs

- `id`

- `routes`

## Usage

````hcl
module "network-route" {
  source = "../../modules/03-network/network-route"
}
````
