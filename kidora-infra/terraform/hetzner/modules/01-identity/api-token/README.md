# api-token

Codifies the Hetzner Cloud authentication contract. It creates nothing.

**Backing:** No provider resource: a token is a credential that must exist before the provider can authenticate.

## Notes

A Hetzner token is 64 lowercase hex characters. Supply it through `token` or export `HCLOUD_TOKEN`, which is what the existing CI workflow already sets. The module emits a SHA-256 prefix so a plan can prove which token was used without printing it.

## Inputs

| Name | Description |
| --- | --- |
| `token` | Hetzner Cloud API token. Leave null to rely on the HCLOUD_TOKEN environment variable instead. |
| `required` | Fail the plan when no token was supplied. Disable in modules that are purely declarative. |
| `env_var_name` | Name of the environment variable the hcloud provider reads its token from. |
| `fingerprint_length` | Number of hex characters of the token hash to expose in outputs. |

## Outputs

- `configured`

- `token_fingerprint`

- `provider_env_var`

## Usage

````hcl
module "api-token" {
  source = "../../modules/01-identity/api-token"
}
````
