# load-balancer-health-check

Expresses a health check as a standalone, reusable object.

**Backing:** No provider resource: health_check is an inline block on hcloud_load_balancer_service.

## Notes

07-load-balancing/load-balancer-service spreads this output into that block. Keeping it separate means one health check definition can be reviewed and reused.

## Inputs

| Name | Description |
| --- | --- |
| `protocol` | Health check protocol. "http" probes a URL, "tcp" only probes that the port accepts connections. |
| `port` | Port to probe when protocol is "tcp". Ignored for "http", which follows the service port. |
| `interval` | Seconds between health checks. |
| `timeout` | Seconds before a check attempt is abandoned. Must be less than interval. |
| `retries` | Consecutive failures before a target is marked unhealthy. |
| `http` | HTTP probe details, used when protocol is "http". |

## Outputs

- `health_check`

## Usage

````hcl
module "load-balancer-health-check" {
  source = "../../modules/07-load-balancing/load-balancer-health-check"
}
````
