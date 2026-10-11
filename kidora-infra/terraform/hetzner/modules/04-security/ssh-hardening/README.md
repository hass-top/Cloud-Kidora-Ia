# ssh-hardening

Renders a cloud-init fragment that hardens SSH and enables fail2ban before any password-based login is possible.

**Backing:** No provider resource: hardening is user_data, not infrastructure.

## Notes

Output `user_data` can be passed straight to 02-compute/server, or handed to 11-operations/cloud-init through `additional_user_data`. Complements, and does not replace, the Ansible ssh_hardening role.

## Inputs

| Name | Description |
| --- | --- |
| `password_authentication` | Allow password-based SSH logins. Keep false in every reachable environment. |
| `permit_root_login` | sshd PermitRootLogin value. |
| `max_auth_tries` | sshd MaxAuthTries. Each attempt is allowed 3 chances by default, which is generous for a brute-force defence. |
| `login_grace_time` | sshd LoginGraceTime in seconds: how long an unauthenticated connection may take to authenticate. |
| `client_alive_interval` | Seconds of silence before sshd sends a keepalive to the client. |
| `client_alive_count_max` | How many unanswered keepalives before the connection is dropped. |
| `allow_tcp_forwarding` | Allow SSH port forwarding. Disable unless a tunnel is genuinely required. |
| `ssh_ciphers` | Explicit sshd Ciphers list. Leave empty to keep the distribution default. |
| `extra_sshd_directives` | Additional sshd_config directives, one per line. Indentation is added automatically. |
| `packages` | Packages installed before hardening is applied. |
| `fail2ban_enabled` | Enable the fail2ban SSH jail. |
| `fail2ban_bantime` | How long a banned IP stays banned. |
| `fail2ban_findtime` | Window over which failed attempts are counted. |
| `fail2ban_maxretry` | Failed attempts within findtime that trigger a ban. |
| `fail2ban_ignoreip` | Addresses exempt from bans. Add your own egress ranges here. |
| `ssh_service_name` | systemd unit to restart. Debian and Ubuntu use "ssh"; RHEL derivatives use "sshd". |

## Outputs

- `user_data`

- `summary`

## Usage

````hcl
module "ssh-hardening" {
  source = "../../modules/04-security/ssh-hardening"
}
````
