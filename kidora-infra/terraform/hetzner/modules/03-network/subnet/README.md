# subnet

Creates subnets inside a private network, either type cloud, server (isolated) or vswitch.

**Backing:** Resource: hcloud_network_subnet.

## Notes

Provider gap: this resource exposes neither labels nor vlan_id. The module keeps an unused `labels` variable so callers stay uniform across resource modules.

## Inputs

| Name | Description |
| --- | --- |
| `subnets` | (see variables.tf) |
| `labels` | Unused by hcloud_network_subnet, which exposes no labels field. Accepted so callers can stay uniform. |

## Outputs

- `id`

- `ip_range`

## Usage

````hcl
module "subnet" {
  source = "../../modules/03-network/subnet"
}
````
