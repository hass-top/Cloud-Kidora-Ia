# load-balancer-target

Adds servers, label selectors or bare IPs to a load balancer pool.

**Backing:** Resource: hcloud_load_balancer_target.

## Notes

Prefer type label_selector: membership then follows server labels, so a replacement server joins the pool without the target changing. Pair with use_private_ip so traffic never crosses the public internet.

## Inputs

| Name | Description |
| --- | --- |
| `targets` | Map of load balancer targets. Map key is the logical name used for wiring. |

## Outputs

- `id`

## Usage

````hcl
module "load-balancer-target" {
  source = "../../modules/07-load-balancing/load-balancer-target"
}
````
