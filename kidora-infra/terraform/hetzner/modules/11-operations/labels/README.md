# labels

Single source of truth for the label scheme.

**Backing:** No provider resource: this module produces the label map and the selectors.

## Notes

Every other module consumes these outputs rather than inventing keys, so a firewall selector and a load balancer target selector cannot drift apart.

## Inputs

| Name | Description |
| --- | --- |
| `project` | Project name, used as a label on every resource. |
| `environment` | Environment name, for example "dev", "preprod" or "prod". |
| `role` | Role of the resource, for example "app", "database" or "monitoring". Leave null for resources that are not part of a role group. |
| `extra` | Additional labels merged into the base set. Use for cost centres, compliance or ownership. |
| `extra_selectors` | Additional ready-made selectors, for label sets this module does not own. |

## Outputs

- `labels`

- `selectors`

- `role_selector`

- `environment_selector`

## Usage

````hcl
module "labels" {
  source = "../../modules/11-operations/labels"
}
````
