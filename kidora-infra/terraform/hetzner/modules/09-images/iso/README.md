# iso

Validates and passes through an ISO reference to mount on a server.

**Backing:** No provider resource and no hcloud_iso data source: nothing can resolve an ISO before boot.

## Notes

hcloud_server.iso takes a name or ID as a plain string, so a typo surfaces at boot rather than at plan. `is_supported` is always false to keep that explicit.

## Inputs

| Name | Description |
| --- | --- |
| `isos` | Map of ISO references to mount on a server. Map key is the logical name used for wiring. |
| `lookup_supported` | Always false. Records that ISO resolution by name is unavailable in the provider, so a typo surfaces at boot rather than at plan. |

## Outputs

- `reference`

- `is_supported`

## Usage

````hcl
module "iso" {
  source = "../../modules/09-images/iso"
}
````
