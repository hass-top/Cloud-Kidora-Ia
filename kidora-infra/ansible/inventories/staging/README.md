# Kidora — Staging (3 servers, Docker Compose)

Ansible deployment of the Kidora stack across three servers, with no
Kubernetes. Everything runs as Docker Compose, images come from GitHub
Container Registry, and the only public web server is the edge.

```
   ┌─ kidora_monitoring ──────────────────┐  ┌─ kidora_app ─────────────────────┐  ┌─ kidora_edge ────────┐
   │ Prometheus          :9090            │  │ MongoDB      :27017  (127.0.0.1)  │  │ nginx      :80/:443  │
   │ Grafana             :3000            │◄─┼─ backend      :8086               │◄─┤ Let's Encrypt        │
   │ Alertmanager        :9093            │  │ frontend     :80                 │  │ Tailscale             │
   │ node-exporter       :9100 (loopback) │  │ backoffice   :8080               │  │ fail2ban (sshd+nginx) │
   │ cAdvisor            :9101 (loopback) │  │ ai-backend   :8000               │  │ UFW 22, 80, 443       │
   │                                       │  │ MinIO        :9000 / :9001       │  │                       │
   │ UFW: 22, 3000, 9090, 9093            │  │ node-exp :9100, cadvisor :9101    │  │                       │
   │      (3000/9090/9093 from edge only) │  │ mongo-exp :9216                  │  │                       │
   │                                       │  │ UFW: 22, 8080, 8086, 8000,       │  │                       │
   │                                       │  │      9000, 9001, 9100, 9101, 9216│  │                       │
   └───────────────────────────────────────┘  └───────────────────────────────────┘  └───────────────────────┘
                                                          ▲
                                            Prometheus scrapes node-exporter,
                                            cAdvisor and the MongoDB exporter
                                            on the other two servers
```

Only the edge has a public address in its firewall rules. Everything else is
`0.0.0.0`-bound *and* UFW-restricted, except MongoDB, which binds loopback and
is reachable only through an SSH tunnel.

MinIO is reachable from two places on purpose: the edge nginx proxies bucket
objects for the public site, and a device on the tailnet reaches the console and
the S3 API directly at `http://<app-tailnet-ip>:9001` and `:9000`. Those two are
the `100.64.0.0/10` rules in `group_vars/app.yml`.

---

## 1. Prerequisites

On your workstation:

```bash
pip install ansible
ansible-galaxy collection install -r requirements.yml
```

The three servers need SSH access with a key that `root` accepts. A `kidora`
user in the `docker` group is created on them by the deployment.

## 2. Set the server addresses

`hosts.ini` ships with `203.0.113.x` — the RFC 5737 documentation range, which
is deliberately not routable, so a forgotten value fails immediately instead of
quietly deploying to the wrong host.

```bash
# Edit the three addresses:
#   kidora_monitoring   203.0.113.11  ->  your monitoring server
#   kidora_app          203.0.113.12  ->  your app server
#   kidora_edge         203.0.113.13  ->  your edge server
$EDITOR ansible/inventories/staging/hosts.ini
```

The entries are bare IP addresses on purpose. Playbooks resolve peers with
`groups['kidora_app'][0]`, so the address *is* the inventory hostname and there
is exactly one place to change it.

## 3. Create the vault

Every secret lives here. Nothing sensitive is in any other file in the repo.

```bash
cd kidora-infra/ansible
ansible-vault edit inventories/staging/group_vars/vault.yml
```

See `inventories/staging/vault.yml.example` for the full list with comments.
The required ones:

| Variable | What it is |
| --- | --- |
| `vault_github_pat` | GitHub PAT with `read:packages` — the images are **private** |
| `vault_mongodb_root_password` | MongoDB root password |
| `vault_mongodb_app_password` | The `readWrite`-only app user |
| `vault_minio_root_password` | MinIO root password |
| `vault_app_secret_key` | JWT signing key; changing it logs everyone out |
| `vault_grafana_admin_password` | Grafana admin |
| `vault_tailscale_auth_key` | From the Tailscale admin console |

Generate values with `openssl rand -base64 36`.

> The old `ansible/group_vars/all.yml` and `ansible/templates/compose.env.j2`
> contain **plaintext** Mongo and MinIO root passwords. Treat those as
> compromised and rotate them.

## 4. DNS and the provider firewall

Before running, point DNS at the edge and open what UFW will allow:

- `kidora.freeddns.org` and `www.kidora.freeddns.org` → the **edge** IP
- inbound **80** and **443** (plus 22 for SSH)

`backoffice.kidora.freeddns.org` should **not** have a public record; it is
served over Tailscale only.

## 5. Deploy

```bash
cd kidora-infra/ansible
ansible-playbook -i inventories/staging/hosts.ini playbooks/staging/main.yml
```

The first run asks for the vault password. Later runs do not, because the
registry credentials are cached on the hosts.

### Order and why it matters

| Playbook | Hosts | What |
| --- | --- | --- |
| `00-preflight.yml` | all | packages, swap, sysctls, fail2ban, **UFW** |
| `10-docker.yml` | all | Docker CE, `kidora` deploy user, GHCR login |
| `15-tailscale.yml` | all | joins the tailnet |
| `20-monitoring.yml` | monitoring | Prometheus, Grafana, Alertmanager |
| `30-app.yml` | app | MongoDB, MinIO, backend, AI, frontend, backoffice |
| `40-edge.yml` | edge | nginx → certbot → nginx again (TLS) |

Three orderings are load-bearing:

- **UFW is applied last in the preflight.** It enables a default-deny policy,
  so Ansible must still be able to reach SSH afterwards.
- **nginx runs twice in `40-edge.yml`.** `nginx -t` fails on a vhost whose
  `ssl_certificate` does not exist, and there is no certificate until certbot
  has run. The first pass installs an HTTP-only bootstrap vhost that serves the
  ACME challenge; the second finds the certificate and swaps in the real
  vhosts. Nothing to toggle by hand.
- **Monitoring before the app.** Prometheus starts scraping the exporters that
  `30-app.yml` installs, so it is briefly incomplete rather than broken.

### Partial runs

```bash
# One stage at a time:
ansible-playbook -i inventories/staging/hosts.ini playbooks/staging/30-app.yml

# By tag:
ansible-playbook -i inventories/staging/hosts.ini playbooks/staging/main.yml --tags monitoring
ansible-playbook -i inventories/staging/hosts.ini playbooks/staging/main.yml --tags app,edge

# Check without changing anything:
ansible-playbook -i inventories/staging/hosts.ini playbooks/staging/main.yml --check --diff
```

## 6. Verify

```bash
ansible-playbook -i inventories/staging/hosts.ini playbooks/staging/verify.yml
```

This is not a formality — it asserts the things that are easy to get wrong:

- every server is default-deny on UFW and Docker is running
- each app service answers
- **no Prometheus target is down** (catches a firewall rule blocking scraping)
- the certificate exists, the public site answers over TLS, and the ACME path
  is still served without a redirect
- the edge can reach all five upstreams
- **the app server's UFW allows 9000/9001 from the tailnet** (this is the rule
  that used to be skipped because it was gated on a block-device fact, which is
  what made MinIO unreachable from a tailnet device)
- **MongoDB does *not* answer from another host** (proves the loopback bind)

---

## Switching off Let's Encrypt staging

`certbot_use_staging: true` in `group_vars/edge.yml` uses LE's test endpoint.
The certificate is not publicly trusted, so browsers warn. Once the vhosts and
DNS are final:

```yaml
certbot_use_staging: false
```

```bash
ansible-playbook -i inventories/staging/hosts.ini playbooks/staging/40-edge.yml
```

`--staging` only changes the ACME endpoint, not the local layout, so the same
`ssl_certificate_path` keeps working and no other change is needed.

## Day-to-day

```bash
# Redeploy the app only
ansible-playbook -i inventories/staging/hosts.ini playbooks/staging/30-app.yml

# Container status
ssh root@kidora-app 'cd /opt/kidora && docker compose ps'

# Logs
ssh root@kidora-app 'docker logs -f kidora-backend'

# Reach MongoDB without opening a port
ssh -L 27017:127.0.0.1:27017 root@kidora-app
#   then point your GUI client at mongodb://127.0.0.1:27017

# Reach MinIO over the tailnet (9000/9001 are never public)
ansible -i inventories/staging/hosts.ini kidora_app -a "tailscale ip -4"
#   then open http://<that-tailnet-ip>:9001 for the console, or use :9000
#   as the S3 endpoint for mc / an SDK

# Where the data lives (bind mounts, so it is easy to back up)
ssh root@kidora-app 'ls -la /opt/kidora/data'
#   mongodb/  minio/  backend-uploads/  ai-uploads/
```

## Backup targets

All state sits at a known path on two servers, and nothing is in an anonymous
Docker volume:

- `kidora_app:/opt/kidora/data/` — MongoDB, MinIO, uploads
- `kidora_monitoring:/opt/kidora/data/` — Prometheus TSDB, Grafana, Alertmanager

For a consistent MongoDB dump use `mongodump` rather than copying the data
directory of a running server.

## What this replaces, and what it does not

This is a **new, self-contained path**. It does not modify the older k3s/Helm
roles (`roles/monitoring`, `roles/mongodb`, `roles/minio`, `roles/helm`, …) or
the `dev` / `prod` inventories. Those remain for the existing single-cluster
setup.

The previous `playbooks/staging/main.yml` chained `../docompose.yml` and
`../minio_db_zot.yml`, neither of which existed, so the staging entry point
could not run at all. It has been replaced by this flow; the old playbooks are
untouched and still reachable individually.

## Troubleshooting

**`docker compose pull` fails with 401**
The images on `ghcr.io` are private. `vault_github_pat` needs the
`read:packages` scope. Check what is cached on the host:
`ssh root@kidora-app 'cat /opt/kidora/.docker/config.json'`

**Grafana shows no data**
Prometheus → Status → Targets. Targets are down when UFW blocks the monitoring
host from `node_exporter_port` on the other two servers:
```bash
ssh root@kidora-monitoring 'curl -s http://<app-ip>:9100/metrics | head'
```

**certbot fails with "too many certificates already issued"**
You are on the production endpoint. Set `certbot_use_staging: true`, wait an
hour, then retry.

**`nginx -t` fails after a manual edit**
Something in `/etc/nginx/conf.d/` is hand-edited and is being validated
alongside the managed files. Remove it — that directory is Ansible-managed.

**The app is up but the SPA cannot reach the API**
Check that `allowed_origins` in `group_vars/all.yml` includes your real origin,
and that the edge is not rate-limiting: `/api/` allows 30 r/s with a burst of 50
per IP.
