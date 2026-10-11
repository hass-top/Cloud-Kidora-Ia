# rdns

Sets reverse DNS for servers, primary IPs, floating IPs and load balancers.

**Backing:** Resource: hcloud_rdns.

## Notes

Exactly one resource ID per entry. Reverse DNS matters for mail deliverability and for anyone reading logs.

## Inputs

| Name | Description |
| --- | --- |
| `entries` | Map of reverse DNS entries. Map key is the logical name used for wiring. |

## Outputs

- `id`

## Usage

````hcl
module "rdns" {
  source = "../../modules/10-dns/rdns"
}
````
