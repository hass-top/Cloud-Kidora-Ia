# load-balancer-service

Defines listeners, TLS handling, sticky sessions and health checks.

**Backing:** Resource: hcloud_load_balancer_service.

## Notes

The protocol decides how TLS is handled: https terminates on the load balancer and needs certificates, tcp passes the encrypted stream through. Health checks are an inline block, so the health check input here is the output of 07-load-balancing/load-balancer-health-check.

## Inputs

| Name | Description |
| --- | --- |
| `services` | Map of load balancer services. Map key is the logical name used for wiring. |

## Outputs

- `id`

## Usage

````hcl
module "load-balancer-service" {
  source = "../../modules/07-load-balancing/load-balancer-service"
}
````
