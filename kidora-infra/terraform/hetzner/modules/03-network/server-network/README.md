# server-network

Attaches an existing server to a subnet with a chosen address and aliases.

**Backing:** Resource: hcloud_server_network.

## Notes

Always sets alias_ips, defaulting to an empty set. The provider detaches and reattaches the network on every apply when alias_ips is null (issue #650), so an explicit empty set keeps plans stable.

## Inputs

| Name | Description |
| --- | --- |
| `attachments` | Map of server-to-network attachments. Map key is the logical name used for wiring. |

## Outputs

- `id`

- `mac_address`

## Usage

````hcl
module "server-network" {
  source = "../../modules/03-network/server-network"
}
````
