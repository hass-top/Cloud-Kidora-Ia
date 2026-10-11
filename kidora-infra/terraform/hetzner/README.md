# Hetzner Cloud infrastructure modules

Terraform modules for Hetzner Cloud, organised by concern. This directory contains
the **module library only**. No environment wires it up yet; see
[Environments](#environments-not-wired-up) below.

- **Provider:** `hetznercloud/hcloud` pinned to `~> 1.69` in every module.
- **Authentication:** the provider reads `HCLOUD_TOKEN` from the environment. No
  module ever accepts a token in configuration, and nothing here creates one.
- **Application layer:** out of scope. Docker, Kubernetes, MongoDB, MinIO, Zot and
  the monitoring stack stay in Ansible, where they already live. Terraform stops at
  the infrastructure boundary and hands over through outputs.

## Layout

```
modules/
  01-identity/       02-compute/       03-network/       04-security/
  05-ip/             06-storage/       07-load-balancing/
  08-availability/   09-images/        10-dns/           11-operations/
```

Each module is self-contained: `main.tf`, `variables.tf`, `outputs.tf`,
`versions.tf`, `README.md`.

## Module catalogue

| Module | Backing resource |
| --- | --- |
| `01-identity/ssh-key` | `hcloud_ssh_key` |
| `01-identity/api-token` | none, auth contract only |
| `02-compute/server` | `hcloud_server` |
| `03-network/network` | `hcloud_network` |
| `03-network/subnet` | `hcloud_network_subnet` |
| `03-network/server-network` | `hcloud_server_network` |
| `03-network/network-route` | `hcloud_network_route` |
| `04-security/firewall` | `hcloud_firewall` |
| `04-security/firewall-rules` | none, policy and normalisation layer |
| `04-security/firewall-attachment` | `hcloud_firewall_attachment` |
| `04-security/ssh-hardening` | none, cloud-init fragment |
| `05-ip/primary-ip` | `hcloud_primary_ip` |
| `05-ip/floating-ip` | `hcloud_floating_ip` |
| `05-ip/floating-ip-assignment` | `hcloud_floating_ip_assignment` |
| `06-storage/volume` | `hcloud_volume` |
| `06-storage/volume-attachment` | `hcloud_volume_attachment` |
| `06-storage/snapshot` | `hcloud_snapshot` |
| `07-load-balancing/load-balancer` | `hcloud_load_balancer` |
| `07-load-balancing/load-balancer-network` | `hcloud_load_balancer_network` |
| `07-load-balancing/load-balancer-target` | `hcloud_load_balancer_target` |
| `07-load-balancing/load-balancer-service` | `hcloud_load_balancer_service` |
| `07-load-balancing/load-balancer-health-check` | none, reusable health check object |
| `07-load-balancing/certificate` | `hcloud_managed_certificate`, `hcloud_uploaded_certificate` |
| `08-availability/placement-group` | `hcloud_placement_group` |
| `08-availability/backups` | none, validates and forwards the `backups` flag |
| `08-availability/disaster-recovery` | `data.hcloud_image`, verifies snapshots |
| `09-images/image` | `data.hcloud_image`, lookup only |
| `09-images/iso` | none, validated passthrough |
| `10-dns/zone` | `hcloud_zone` |
| `10-dns/dns` | `hcloud_zone_rrset` |
| `10-dns/rdns` | `hcloud_rdns` |
| `11-operations/labels` | none, canonical label map |
| `11-operations/cloud-init` | none, renders `user_data` |
| `11-operations/monitoring` | none, scrape target handoff |

## What the provider cannot do

This is the part worth reading before designing anything new. Each row was
verified against the v1.69.0 provider source, not inferred from the registry page.
Six capabilities in the original plan have no backing resource at all, so rather
than shipping modules that silently do nothing, they are either modelled as
explicit non-resource modules or removed.

| Requested | Reality in v1.69.0 | How this library handles it |
| --- | --- | --- |
| `01-identity/api-token` | No token resource exists. A token must exist before the provider can authenticate. | `01-identity/api-token` codifies the contract, validates the token format, and exposes a SHA-256 fingerprint for audit logs. |
| `02-compute/server-group` | No `hcloud_server_group` resource. | **Removed.** Use `08-availability/placement-group` and label selectors, which is the only grouping primitive the provider exposes. |
| `02-compute/rescue` | No `rescue` reference anywhere in the provider source. Rescue is the API action `POST /servers/{id}/actions/enable_rescue`. | **Removed.** Documented as a runbook step; use the console or the `hcloud` CLI. |
| `04-security/firewall-rules` | Rules are inline `rule {}` blocks on `hcloud_firewall`. There is no separate rules resource. | `04-security/firewall-rules` is a normalisation and audit layer, not a resource wrapper. |
| `06-storage/backup`, `08-availability/backups` | `hcloud_server.backup_window` is **Computed and Deprecated**; `hcloud_volume` has no backup argument whatsoever. | `08-availability/backups` is the single canonical module. It manages the on/off switch only and reports `backup_window_applied = false` and `volume_backups_supported = false` so the gap is visible in plan output. |
| `07-load-balancing/load-balancer-health-check` | `health_check` is an inline block on `hcloud_load_balancer_service`. | Modelled as a standalone object that the service module spreads into the inline block. |
| `09-images/image` | `hcloud_image` exists as a data source only; `internal/image/` has no resource file. Converting a server to an image is an API action. | `09-images/image` is lookup-only, and exposes a `deprecating` output so image deprecations are caught before a rebuild fails. |
| `09-images/iso` | The `hcloud_iso` data source was removed from the provider. `hcloud_server.iso` takes a raw name or ID string. | `09-images/iso` validates and passes through. `is_supported` is always false because a typo surfaces at boot, not at plan. |
| `09-images/snapshot` | Duplicate of `06-storage/snapshot`. | **Removed.** One resource type is managed in one place. |
| `02-compute/placement-group` | Duplicate of `08-availability/placement-group`. | **Removed.** Spread is an availability property, so `08` is canonical. |
| `04-security/ssh-hardening` vs `11-operations/cloud-init` | Both are `user_data`; the repo also already has an Ansible `ssh_hardening` role. | Kept as two modules with distinct jobs: `ssh-hardening` produces a hardening fragment, `cloud-init` produces the base document and appends fragments. |

Two further gaps that are not modules but do bite:

- **`hcloud_network_subnet` has no `labels` and no `vlan_id`.** The module keeps an
  unused `labels` variable so callers stay uniform, and type `server` subnets are
  documented as isolated rather than VLAN-configurable.
- **`hcloud_network` exposes `expose_routes_to_vswitch`,** not the older
  `expose_routes_to_vpc` / `expose_routes_to_vpn` flags.
## Conventions

These hold for every module, and are worth preserving in review.

- **One resource type per module.** Two modules managing the same provider resource
  is how drift starts.
- **`for_each` over maps, never `count`.** Map keys become stable resource addresses
  and survive reordering; count makes them positional and fragile.
- **Nothing hardcoded.** No environment, project or region name appears in any
  module. Everything is an input.
- **Every variable has `description`, `type` and a `default`.** `description` is
  what `terraform-docs` and the console show, so an undocumented variable is a
  defect.
- **Validation at the boundary.** Ports, protocols, directions, CIDRs, mutually
  exclusive arguments and cardinality are all checked with `validation` blocks, so
  a mistake fails at plan rather than at apply.
- **Singular inputs, plural maps.** A module that manages several resources takes a
  map; a module that renders one artefact takes singular values.
- **Provider gaps are visible.** Where a capability does not exist, the module
  exposes a boolean output that says so, instead of quietly omitting the code.

### Typing notes worth knowing

`hcloud_network_subnet.id` and the `subnet_id` argument are **strings**, while
`network_id`, `server_id` and other IDs are **numbers**. Mixing them up produces a
plan-time type error rather than a subtle runtime failure, which is the intended
behaviour, but it is the single most common mistake when wiring these modules.

## Composition

How the pieces fit together. This is illustrative, not a deployable file: no
environment directory exists yet.

```hcl
# Identity and the shared label contract.
module "auth" {
  source = "../../modules/01-identity/api-token"
}

module "labels" {
  source      = "../../modules/11-operations/labels"
  project     = "kidora"
  environment = "preprod"
}

module "ssh_keys" {
  source = "../../modules/01-identity/ssh-key"
  keys = {
    admin = {
      name       = "kidora-preprod-admin"
      public_key = file("~/.ssh/id_ed25519.pub")
    }
  }
}

# Network, then subnet, then a stable public address.
module "network" {
  source = "../../modules/03-network/network"
  networks = {
    main = { name = "kidora-preprod", ip_range = "10.0.0.0/16" }
  }
}

module "subnet" {
  source     = "../../modules/03-network/subnet"
  subnets = {
    eu = {
      network_id   = module.network.id["main"]
      network_zone = "eu-central"
      ip_range     = "10.0.1.0/24"
    }
  }
}

module "primary_ip" {
  source = "../../modules/05-ip/primary-ip"
  primary_ips = {
    app = { name = "kidora-preprod-app", location = "fsn1" }
  }
}

# Firewall rules are normalised first, then applied, then attached by label.
module "firewall_rules" {
  source = "../../modules/04-security/firewall-rules"
  rules = {
    ssh = {
      protocol   = "tcp"
      port       = "22"
      source_ips = ["203.0.113.10/32"] # admin egress only
    }
    https = {
      protocol   = "tcp"
      port       = "443"
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }
}

module "firewall" {
  source = "../../modules/04-security/firewall"
  firewalls = {
    public = {
      name  = "kidora-preprod"
      rules = module.firewall_rules.rules
    }
  }
}

# Boot configuration: base document plus the hardening fragment.
module "hardening" {
  source = "../../modules/04-security/ssh-hardening"
}

module "cloud_init" {
  source       = "../../modules/11-operations/cloud-init"
  hostname     = "kidora-preprod-app"
  environment  = "preprod"
  project      = "kidora"

  ssh_authorized_keys = [file("~/.ssh/id_ed25519.pub")]

  additional_user_data = [module.hardening.user_data]
}

# Compute last: it needs keys, firewall, subnet and user_data.
module "servers" {
  source = "../../modules/02-compute/server"
  labels = module.labels.labels

  servers = {
    app = {
      name            = "kidora-preprod-app"
      server_type     = "cpx31"
      location        = "fsn1"
      image           = "debian-12"
      ssh_keys        = [module.ssh_keys.id["admin"]]
      firewall_ids    = [module.firewall.id["public"]]
      primary_ipv4_id = module.primary_ip.id["app"]
      user_data       = module.cloud_init.user_data

      networks = [
        { subnet_id = module.subnet.id["eu"], ip = "10.0.1.10" }
      ]
    }
  }
}

# Monitoring consumes the same server map, so the two cannot disagree.
module "monitoring" {
  source      = "../../modules/11-operations/monitoring"
  environment = "preprod"

  targets = {
    for k, v in module.servers.ipv4_address : k => {
      name = k
      ip   = v
      role = "app"
    }
  }
}
## Constraints to keep in mind

- **Backup windows cannot be set by Terraform.** Not for servers (the attribute is
  computed and deprecated) and not for volumes (no attribute exists). Set the project
  backup window in the Hetzner console; Terraform can only toggle backups on and
  off. `02-compute/server` exposes a read-only `backup_window` output so you can
  verify the console setting actually took effect.
- **DNS only works for Hetzner-authoritative zones.** `10-dns/zone` creates a
  primary zone whose nameservers you must delegate to. The `freeddns.org` domain
  used elsewhere in this repo cannot be managed by these modules, because
  `hcloud_zone_rrset` records only resolve where Hetzner is authoritative. Use
  `kidora-prod.com` / `kidora-preprod.com`, or keep DNS elsewhere.
- **A load balancer takes a Primary IP, not a Floating IP.** `hcloud_floating_ip`
  cannot be attached to one. Use `05-ip/primary-ip` with
  `assignee_type = "load_balancer"`.
- **Volume data is never in a snapshot.** Any rebuild plan needs
  `06-storage/volume-attachment` as well as `06-storage/snapshot`.
- **Firewall attachment cannot protect a first boot.** `hcloud_firewall_attachment`
  only attaches to a running server. Use `firewall_ids` on `02-compute/server` when
  the rules must be enforced from the first packet.
- **`hcloud_snapshot` cannot snapshot a volume** and exposes no `name`.
- **Custom images cannot be created by Terraform.** Only snapshots and system
  images are addressable.

## Environments (not wired up)

This library is deliberately not connected to anything yet. `environments/preprod`
and `environments/prod` exist in this directory and **are broken**; they were left
untouched. Recording the findings here so the decision is deliberate rather than
accidental.

What is wrong with them:

1. **They are Vultr configurations, not Hetzner ones.** Both `providers.tf` files
   declare `provider "vultr"` with `vultr/vultr` and a `vultr_api_key` variable.
   Nothing in them references the hcloud provider.
2. **Every module `source` path is dead.** They point at
   `//kidora-infra/terraform/modules/...`, a path that no longer exists. The Vultr
   modules were moved to `terraform/vultr/modules/`. `terraform init` cannot
   resolve them, so the configurations cannot currently be initialised, planned or
   applied.
3. **Module names are Vultr concepts.** `vultr-server` with `plan` and `os_id`
   arguments has no Hetzner equivalent; the equivalent is `02-compute/server` with
   `server_type` and `image`.
4. **The backend is set for two workspaces,** `kidora-preprod` and `kidora-prod`,
   in the same Terraform Cloud organisation. That is fine as a layout, but it is
   inherited from the Vultr era and should be confirmed before reuse.
5. **`prod` contains an unresolved placeholder.** The SSH firewall rule uses
   `subnet = "YOUR_ADMIN_IP"`, noted as outstanding in that directory's `TODO.md`.
   That is a live risk: SSH is currently open to the world on prod.
6. **The Ansible playbooks still point at the old layout.**
   `ansible/playbooks/preprod/terraform.yml` resolves `terraform_dir` to
   `terraform/environments/preprod`, and those playbooks read
   `terraform_data.dev_server_ip` or `.ip_address` from the Terraform outputs, which
   do not exist in the current output set.

Also worth noting before this is used in CI: `kidora-infra/.gitignore` ignores
`.terraform.lock.hcl` globally. For root modules that is the wrong default, because
the lock file is what pins provider versions; here the modules carry an explicit
`~> 1.69` constraint in `versions.tf` instead, which is a reasonable substitute.
The existing `terraform.yml` workflow runs `working-directory: terraform`, which
holds no root module, and pins Terraform 1.5.0 while the local toolchain is 1.16.2.

One more thing to be aware of: `environments/preprod/main.tf` and
`environments/prod/main.tf` are **not** `terraform fmt` clean. The `modules/` subtree
in this directory is, and the CI format step should be scoped to it, or those two
files will fail the check before anything else is reached.

## Validating a change

Every module is a standalone root module, so the library validates without any
environment or credentials:

```bash
# Syntax, formatting and schema, per module.
terraform fmt -check -recursive modules
for d in modules/*/*/; do
  ( cd "$d" && terraform init -backend=false && terraform validate )
done
```

`terraform validate` compiles the real provider schema, so it catches a wrong
resource name, a wrong argument name or a wrong type immediately. That is how the
provider gaps recorded above were confirmed rather than assumed.