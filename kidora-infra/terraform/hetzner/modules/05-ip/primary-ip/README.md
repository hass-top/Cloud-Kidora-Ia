# primary-ip

Pre-creates primary IPv4 and IPv6 addresses so a server keeps its address across a replacement.

**Backing:** Resource: hcloud_primary_ip.

## Notes

Use the `ipv4` output for the `primary_ipv4_id` argument of 02-compute/server. This is how a public address survives a rebuild; a Floating IP does not, because there is a window during recreation when it is unassigned.

## Inputs

| Name | Description |
| --- | --- |
| `primary_ips` | Map of primary IPs to manage. Map key is the logical name used for wiring. |
| `labels` | Labels applied to every primary IP created by this module. |

## Outputs

- `id`

- `ip_address`

- `ipv4`

## Usage

````hcl
module "primary-ip" {
  source = "../../modules/05-ip/primary-ip"
}
````
