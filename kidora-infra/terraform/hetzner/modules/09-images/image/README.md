# image

Resolves an existing image to an ID that hcloud_server.image accepts.

**Backing:** Data source only, by design: there is no image resource.

## Notes

Turning a server into an image is an API action (POST /servers/{id}/actions/create_image) that Terraform cannot express. Create one by snapshotting with 06-storage/snapshot, then look it up here. The `deprecating` output surfaces images with a deprecation date before a rebuild breaks.

## Inputs

| Name | Description |
| --- | --- |
| `images` | Map of images to look up. Map key is the logical name used for wiring. |

## Outputs

- `id`

- `details`

- `deprecating`

## Usage

````hcl
module "image" {
  source = "../../modules/09-images/image"
}
````
