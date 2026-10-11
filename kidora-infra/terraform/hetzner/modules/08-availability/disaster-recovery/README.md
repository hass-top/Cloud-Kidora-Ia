# disaster-recovery

Verifies recovery points exist and turns them into a rebuild runbook.

**Backing:** Data source: hcloud_image, used to resolve each snapshot by ID.

## Notes

Creates nothing. The verification is the value: hcloud_snapshot exposes only server_id, so a snapshot ID that no longer resolves would otherwise surface mid-incident. Reports recovery points that already carry a deprecation date.

## Inputs

| Name | Description |
| --- | --- |
| `recovery_points` | Map of snapshots intended as recovery points. Map key is the logical name used for wiring. |
| `primary_region` | Region the primary workload runs in, recorded for cross-region decisions. |

## Outputs

- `recovery_points`

- `at_risk`

- `objectives`

- `runbook`

## Usage

````hcl
module "disaster-recovery" {
  source = "../../modules/08-availability/disaster-recovery"
}
````
