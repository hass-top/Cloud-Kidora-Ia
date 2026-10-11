# backups

Validates the desired backup window and hands the on/off switch to 02-compute/server.

**Backing:** No provider resource: backups are the `backups` argument on hcloud_server.

## Notes

Provider gap, and the reason this module is thin. hcloud_server.backup_window is computed and deprecated in 1.69, and hcloud_volume has no backup argument at all, so the window is a project setting made in the console. `backup_window_applied` and `volume_backups_supported` are always false and say so in plan output instead of leaving the absence of code to be inferred.

## Inputs

| Name | Description |
| --- | --- |
| `enabled` | Enable automatic server backups. Backups are billed per server and are not included in the instance price. |
| `window` | Requested backup window in UTC. Hetzner offers exactly three: 00-06, 02-08 and 22-02. Declared intent only; see the module README. |
| `assert_window_applied` | Set to false only when the console window is known to match `window`. The mismatch is reported either way, so this guards against assuming the setting took effect. |

## Outputs

- `backups`

- `requested_window`

- `backup_window_applied`

- `server_backups_supported`

- `volume_backups_supported`

- `summary`

## Usage

````hcl
module "backups" {
  source = "../../modules/08-availability/backups"
}
````
