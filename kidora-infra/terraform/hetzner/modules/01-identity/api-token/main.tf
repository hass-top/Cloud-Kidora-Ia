# The Hetzner Cloud provider cannot create API tokens: a token is a credential
# that must already exist before the provider can authenticate. This module
# therefore does not create infrastructure. It codifies the authentication
# contract so environments fail fast and loudly instead of erroring deep inside
# the provider, and it emits a non-reversible fingerprint for audit logs.
#
# Supply the token either as `token` (preferable, kept in a secret store) or by
# exporting the environment variable named by `env_var_name` (HCLOUD_TOKEN by
# default, which is what CI already sets).

check "api_token_supplied" {
  assert {
    condition     = !var.required || var.token != null
    error_message = <<-EOT
      No Hetzner Cloud API token was supplied to the api-token module.
      Set the `token` variable, or export ${var.env_var_name} in the environment
      so the hcloud provider can authenticate.
    EOT
  }
}