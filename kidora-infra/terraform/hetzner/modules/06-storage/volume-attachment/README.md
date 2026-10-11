# volume-attachment

Attaches existing volumes to servers, with optional automount.

**Backing:** Resource: hcloud_volume_attachment.

## Notes

Volume data is never captured in a server snapshot, so this module is part of any rebuild plan.

## Inputs

| Name | Description |
| --- | --- |
| `attachments` | Map of volume attachments. Map key is the logical name used for wiring. |

## Outputs

- `id`

## Usage

````hcl
module "volume-attachment" {
  source = "../../modules/06-storage/volume-attachment"
}
````
