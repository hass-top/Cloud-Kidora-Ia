# firewall-attachment

Attaches an existing firewall to servers by ID or by label selector.

**Backing:** Resource: hcloud_firewall_attachment.

## Notes

Hetzner allows only one attachment resource per firewall, and everything it protects must be listed on it. Prefer a label selector. Note the resource cannot protect a server before its first boot; use 02-compute/server `firewall_ids` for that.

## Inputs

| Name | Description |
| --- | --- |
| `attachments` | Map of firewall attachments. Map key is the logical name, which must be unique per firewall. |

## Outputs

- `id`

## Usage

````hcl
module "firewall-attachment" {
  source = "../../modules/04-security/firewall-attachment"
}
````
