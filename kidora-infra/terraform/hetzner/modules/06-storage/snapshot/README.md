# snapshot

Creates snapshots of servers, the recovery points used for rebuilds.

**Backing:** Resource: hcloud_snapshot.

## Notes

This is the canonical snapshot module; 09-images/snapshot was removed so one resource type is managed in one place. Provider gap: the resource takes server_id only, cannot snapshot a volume, and exposes no `name`.

## Inputs

| Name | Description |
| --- | --- |
| `snapshots` | Map of server snapshots to create. Map key is the logical name used for wiring. |
| `labels` | Labels applied to every snapshot created by this module. |

## Outputs

- `id`

- `description`

## Usage

````hcl
module "snapshot" {
  source = "../../modules/06-storage/snapshot"
}
````
