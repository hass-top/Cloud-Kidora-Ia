# server

Creates the compute: servers, their public interfaces, private network attachments, firewall attachment and boot configuration.

**Backing:** Resource: hcloud_server.

## Notes

Firewalls are attached through `firewall_ids` rather than hcloud_firewall_attachment so rules are enforced on first boot. Provider gap: `backup_window` is computed and deprecated, so only the on/off switch can be managed; the window is a project setting. There is no rescue support.

## Inputs

| Name | Description |
| --- | --- |
| `servers` | Map of servers to manage. Map key is the logical name used for wiring; value is the server definition. |
| `labels` | Labels applied to every server created by this module. |

## Outputs

- `id`

- `ipv4_address`

- `ipv6_address`

- `ipv6_network`

- `private_ips`

- `server_ids`

- `backup_window`

- `backups_enabled`

## Usage

````hcl
module "server" {
  source = "../../modules/02-compute/server"
}
````
