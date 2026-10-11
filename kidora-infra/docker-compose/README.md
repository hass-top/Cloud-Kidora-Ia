# Kidora — Docker Compose (single source of truth)

This directory is the **only** place in the Kidora project where Docker Compose
files live. The per-repository `docker-compose.yml` files that used to sit in
`Client-Kidora-backend`, `Client_kidora_frontend` and `Intelligence-artificielle`
were removed so that the stack cannot drift into three different versions of
"how to run Kidora".

All three application images are pulled from **GitHub Container Registry**,
published by each repository's own CI. Nothing is built here.

| Image | Published by |
| --- | --- |
| `ghcr.io/hass-top/kidora-backend` | `Client-Kidora-backend` CI |
| `ghcr.io/hass-top/kidora-frontend` | `Client_kidora_frontend` CI |
| `ghcr.io/hass-top/kidora-ia-center` | `Intelligence-artificielle` CI |

> These packages are **private**. Log in once before your first pull:
> ```bash
> echo "$GITHUB_PAT" | docker login ghcr.io -u <github-user> --password-stdin
> ```
> The PAT needs the `read:packages` scope.

## Which file do I want?

| File | Use it for |
| --- | --- |
| **`docker-compose.dev.yml`** | **Local development** — the whole app: MongoDB, MinIO, backend, AI, frontend. This is the one you want. |
| `docker-compose-ai.yml` | A host that runs *only* the AI service, fronted by Caddy for TLS. |
| `docker-compose-infra.yml` | Production infrastructure: MinIO, MongoDB. |
| `docker-compose-app.yml` | Production application: backend, AI, frontend, nginx. |

`docker-compose-infra.yml` and `docker-compose-app.yml` are composed from the
fragments in `services/`, and are what the Ansible playbooks deploy.

## Local development

```bash
# 1. one-time: authenticate to the private registry
echo "$GITHUB_PAT" | docker login ghcr.io -u <github-user> --password-stdin

# 2. one-time: create the env file and fill in the three required secrets
cp .env.example .env

# 3. start everything
cd ..
docker compose -f docker-compose/docker-compose.dev.yml up -d

# 4. watch it
docker compose -f docker-compose/docker-compose.dev.yml logs -f backend
```

| URL | What |
| --- | --- |
| <http://localhost:5173> | The SPA. Its baked-in nginx also proxies `/api`, `/ws` and `/uploads`. |
| <http://localhost:8086> | Spring Boot API (Swagger at `/swagger-ui.html`). |
| <http://localhost:8000> | AI service (`/docs`, `/health`). |
| <http://localhost:9001> | MinIO console. |
| <http://localhost:27017> | MongoDB, for a GUI client. |
| `https://kidora-backoffice.<tailnet>.ts.net` | Backoffice SPA, over Tailscale only — there is no `localhost` URL. |
| `https://kidora-backoffice.<tailnet>.ts.net:8443` | MinIO Console, over Tailscale only — the local console stays `http://localhost:9001`. |

Stop it, or stop it *and* wipe the data:

```bash
docker compose -f docker-compose/docker-compose.dev.yml down      # keep data
docker compose -f docker-compose/docker-compose.dev.yml down -v   # wipe data
```

### Why the dev stack has no `nginx` service

The frontend image already contains an nginx that serves the SPA **and** proxies
`/api/`, `/ws/` and `/uploads/` to `http://backend:8086`. The separate
`services/07-nginx.yml` exists for **production**, where it terminates TLS in
front of everything. In dev you talk to the frontend directly, so an extra proxy
would only add a hop.

### The backoffice is reached over Tailscale

The `backoffice` service is deliberately **not published to the host**. It has no
`ports:` section, only `expose: "80"`, so Docker never binds it to the host and
there is no `localhost` URL for it.

| | |
| --- | --- |
| Container port | **80** |
| In-network address | `http://backoffice:80` |
| Reached by humans via | `https://kidora-backoffice.<tailnet>.ts.net` |

**The container port is 80, not 5173.** The image compiles the SvelteKit SPA to
static files with `@sveltejs/adapter-static` and serves them with nginx
(`backoffice/Dockerfile`). 5173 is the Vite *dev* server, which only exists when
you run `npm run dev` on a workstation — it is not in the image. A `5173` mapping
would bind a host port that nothing answers on.

Its own bundled nginx proxies `/api/`, `/uploads/` and `/ws/` to
`http://backend:8086`, so the SPA's API calls stay same-origin.

How Tailscale reaches it: the `tailscale` service in `docker-compose.dev.yml`
uses `network_mode: "service:backoffice"`, so it **shares the backoffice's
network namespace**. `tailscaled` brings `tun0` up inside the namespace where
that nginx already listens on `:80`, which makes the tailnet address *be* the
backoffice. A Tailscale container with a namespace of its own joins the tailnet
and appears in the admin console, but has nothing listening on it — that was the
previous configuration, and it is why the backoffice never loaded.

| URL | Notes |
| --- | --- |
| `https://kidora-backoffice.<tailnet>.ts.net` | via Tailscale Serve, real Let's Encrypt certificate |
| `http://kidora-backoffice.<tailnet>.ts.net` | direct on `:80`, no TLS |
| `http://<tailnet-ip>` | the same thing by address |

`./tailscale/serve.json` defines the Serve mapping: TLS on 443 → the SPA on 80,
with Funnel explicitly **off** (this is an admin surface and must never get a
public URL). Serve needs **HTTPS Certificates** enabled on the admin console's
DNS page; without it the `https://` URL does not come up, while the `http://` one
still works. Find your tailnet name with:

```bash
docker exec kidora-tailscale tailscale status
```

### The MinIO Console is on the same tailnet node, on port 8443

MinIO does not get a tailnet node of its own. The `tailscale` sidecar already
fronts the backoffice and is attached to `kidora_net`, so it can reach
`http://minio:9001` by Compose name — `./tailscale/serve.json` therefore adds a
second HTTPS port next to 443:

| | |
| --- | --- |
| Container port | **9001** — the Console (`9000` is the S3 API) |
| In-network address | `http://minio:9001` |
| Reached by humans via | `https://kidora-backoffice.<tailnet>.ts.net:8443` |

Two things that are deliberate:

- **Not a `/minio/` handler on 443.** The MinIO Console cannot be served from a
  sub-path (upstream `minio/minio#15859`), so it needs a root path; and a
  Tailscale node has exactly one certificate, carrying the backoffice's name,
  which 443 is already using.
- **Funnel stays off on 8443**, exactly as on 443. The Console is an
  administrative surface and must never be given a public URL.

MinIO must be told the Console's own URL explicitly, because the post-login
redirect is not derived from how Serve forwards the request:

```bash
MINIO_BROWSER_REDIRECT_URL=https://kidora-backoffice.<tailnet>.ts.net:8443
```

That is MinIO's documented requirement for a Console behind a reverse proxy.
Leaving it unset keeps the plain local behaviour on `http://localhost:9001`.

The S3 API on 9000 stays a host port for local development (`mc`, SDKs) and is
**not** on the tailnet. To put it there too, add `"9443": { "HTTPS": true }` to
`TCP` and a `"${TS_CERT_DOMAIN}:9443"` handler pointing at `http://minio:9000` in
`serve.json`, then set `MINIO_SERVER_URL` to match — SigV4 signatures cover the
Host header, so presigned URLs generated against another hostname will not
verify.

### Required secrets

`.env.example` documents everything. Five values are **required** — the compose
file writes them as `:?`, so it refuses to start without them rather than falling
back to something weak:

- `MONGODB_URI`
- `MONGODB_PASSWORD` — the root password of the bundled `mongo:8` container
- `MINIO_ROOT_PASSWORD`
- `APP_SECRET_KEY`
- `TS_AUTHKEY` — the backoffice is reached over Tailscale, and the `tailscale`
  service exits without it

The AI provider keys (`GROQ_API_KEY`, …) are optional — the service starts
without them, but the features that need them fail until they are set.

## Pinning a specific build

The images default to `:latest` with `pull_policy: always`, so you always get
what CI last pushed. To pin an exact commit for reproducible testing:

```bash
BACKEND_IMAGE=ghcr.io/hass-top/kidora-backend:1a2b3c4 \
  docker compose -f docker-compose/docker-compose.dev.yml up -d
```

## Scripts

`scripts/pull-images.sh` pulls the three application images and reports which
ones changed. Needs Git Bash, WSL, or a POSIX shell. Not on Windows? Run the
`docker pull` commands by hand — the logic is only a loop.

The old Vultr-era helpers (`sync_images.sh`, `list_vultr_images.sh`,
`vultr-registry-list.sh`) were removed: they targeted `fra.vultrcr.com`, and
`sync_images.sh` contained a hardcoded absolute path from someone's desktop.
