# ssh-key

Manages the SSH public keys that grant access to the fleet.

**Backing:** Resource: hcloud_ssh_key.

## Notes

Keys are attached to servers through the `ssh_keys` argument of 02-compute/server, not by a separate resource, so they are in place before first boot.

## Inputs

| Name | Description |
| --- | --- |
| `keys` | Map of SSH keys to manage. Map key is the logical name used for wiring; value is the key definition. |
| `labels` | Labels applied to every SSH key created by this module. |

## Outputs

- `id`

- `key_ids`

- `fingerprint`

## Usage

````hcl
module "ssh-key" {
  source = "../../modules/01-identity/ssh-key"
}
````
