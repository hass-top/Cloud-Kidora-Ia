# READ ONLY, BY DESIGN. The provider exposes hcloud_image as a data source only:
# there is no image resource, because turning a server into an image is an API
# action (POST /servers/{id}/actions/create_image) that Terraform cannot express.
#
# So this module resolves an existing image to an ID that hcloud_server.image
# accepts. To create one, take a snapshot with 06-storage/snapshot, or convert a
# server through the hcloud CLI, then look the result up here.
data "hcloud_image" "this" {
  for_each = var.images

  id                 = each.value.id
  name               = each.value.name
  with_architecture  = each.value.architecture
  with_selector      = each.value.selector
  most_recent        = each.value.most_recent
  include_deprecated = each.value.include_deprecated
}