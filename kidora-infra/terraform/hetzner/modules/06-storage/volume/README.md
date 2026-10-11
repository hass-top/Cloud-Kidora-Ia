# volume

Creates block storage volumes, either standalone or attached at creation.

**Backing:** Resource: hcloud_volume.

## Notes

Exactly one of location or server_id. Use location plus 06-storage/volume-attachment when attaching more than one volume to a server, which is what the provider docs require. Provider gap: no backup argument exists for volumes in 1.69.

## Inputs

| Name | Description |
| --- | --- |
| `volumes` | Map of block storage volumes to manage. Map key is the logical name used for wiring. |
| `labels` | Labels applied to every volume created by this module. |

## Outputs

- `id`

- `linux_device`

- `location`

## Usage

````hcl
module "volume" {
  source = "../../modules/06-storage/volume"
}
````
