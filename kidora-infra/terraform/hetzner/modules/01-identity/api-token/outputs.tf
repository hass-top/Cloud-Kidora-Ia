# nonsensitive() wraps the whole expression on purpose. Applying it to only one
# branch of a conditional still leaves the comparison against a sensitive value
# in the result, and Terraform rejects the output. A SHA-256 prefix of a
# 64-character token reveals nothing usable against the API, and having a stable
# fingerprint in plan output is the point of this module: it proves which token was
# used without printing it.
output "configured" {
  description = "True when a token was supplied through the `token` variable."
  value       = nonsensitive(var.token != null)
}

output "token_fingerprint" {
  description = "Non-reversible SHA-256 prefix of the supplied token, safe to log. Null when no token was supplied."
  value       = nonsensitive(var.token == null ? null : substr(sha256(var.token), 0, var.fingerprint_length))
}

output "provider_env_var" {
  description = "Environment variable the hcloud provider will read the token from when `token` is null."
  value       = nonsensitive(var.token == null ? var.env_var_name : null)
}