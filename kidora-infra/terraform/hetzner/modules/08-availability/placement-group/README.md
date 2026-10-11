# placement-group

Spreads servers across different physical hosts.

**Backing:** Resource: hcloud_placement_group.

## Notes

Canonical location: spread is an availability property, so this lives in 08 rather than 02. A spread group holds at most 10 servers. There is no server-group resource in the provider, so this is the only placement primitive available.

## Inputs

| Name | Description |
| --- | --- |
| `placement_groups` | Map of placement groups to manage. Map key is the logical name used for wiring. |
| `type` | Placement group type. "spread" distributes members across different physical hosts. |
| `labels` | Labels applied to every placement group created by this module. |

## Outputs

- `id`

- `name`

## Usage

````hcl
module "placement-group" {
  source = "../../modules/08-availability/placement-group"
}
````
