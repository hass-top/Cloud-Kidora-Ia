# cloud-init

Renders the base cloud-config document for a node.

**Backing:** No provider resource: this module produces user_data.

## Notes

Fragment output is byte-stable for stable inputs, so a server user_data never churns between plans. Fragments from other modules are appended as additional cloud-init documents separated by ---. Deliberately does not write secret-bearing files; those belong in the vault path used by Ansible.

## Inputs

| Name | Description |
| --- | --- |
| `hostname` | Hostname to set on the node. |
| `user_name` | Unprivileged user created on the node. |
| `ssh_authorized_keys` | Public keys granted sudo on the node. An empty list leaves only key-based root access, which breaks cloud-init if the wrong key was supplied. |
| `timezone` | System timezone. |
| `manage_etc_hosts` | Let cloud-init manage /etc/hosts so the hostname resolves locally. |
| `packages` | Packages installed on every boot. |
| `environment` | Environment name written to /etc/environment, so later tooling knows where it is running. |
| `project` | Project name written to /etc/environment. |
| `node_exporter` | Value written as NODE_EXPORTER_ENABLED. Set to "true" on hosts that should be scraped. Left null the variable is omitted entirely. |
| `additional_user_data` | Extra cloud-init fragments, for example the output of 04-security/ssh-hardening. Each must be a complete YAML document. |

## Outputs

- `user_data`

- `fragment_count`

## Usage

````hcl
module "cloud-init" {
  source = "../../modules/11-operations/cloud-init"
}
````
