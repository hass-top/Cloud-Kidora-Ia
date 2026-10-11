# floating-ip-assignment

Moves an existing floating IP between servers without recreating the address.

**Backing:** Resource: hcloud_floating_ip_assignment.

## Notes

Targets servers only. Hetzner load balancers take a Primary IP, not a Floating IP.

## Inputs

| Name | Description |
| --- | --- |
| `assignments` | Map of floating IP to server assignments. Map key is the logical name used for wiring. |

## Outputs

- `id`

## Usage

````hcl
module "floating-ip-assignment" {
  source = "../../modules/05-ip/floating-ip-assignment"
}
````
