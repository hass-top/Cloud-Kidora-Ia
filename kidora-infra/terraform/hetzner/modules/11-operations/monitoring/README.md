# monitoring

Produces the Prometheus scrape target list from the same server map that built the infrastructure.

**Backing:** No provider resource: the provider has no metric or exporter resource.

## Notes

The monitoring stack stays in Ansible and Helm, where it already lives. `missing_address` reports targets marked scrapeable with no address, which is a cheaper signal than debugging an empty target list.

## Inputs

| Name | Description |
| --- | --- |
| `targets` | Map of scrape targets, normally derived from the output of 02-compute/server. |
| `environment` | Environment these targets belong to, used in job and instance labels. |
| `selector` | Label selector that identifies the managed hosts, usually the output of 11-operations/labels.environment_selector. |
| `scrape_interval` | Seconds between scrapes. |
| `scrape_timeout` | Per-scrape timeout. Must not exceed scrape_interval. |

## Outputs

- `targets`

- `target_list`

- `targets_by_role`

- `missing_address`

- `labels`

## Usage

````hcl
module "monitoring" {
  source = "../../modules/11-operations/monitoring"
}
````
