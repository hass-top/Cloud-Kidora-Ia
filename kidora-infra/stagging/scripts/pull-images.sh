#!/usr/bin/env bash
# =============================================================================
#  pull-images.sh - pull the Kidora app images from GitHub Container Registry
# =============================================================================
#  Pulls the four application images that the CI pipelines publish to GHCR
#  and reports what changed, so you can confirm the local stack is running the
#  build you expect.
#
#  Replaces the Vultr-era scripts (sync_images.sh / list_vultr_images.sh), which
#  referenced fra.vultrcr.com and a hardcoded desktop path.
#
#  Usage:
#      ./pull-images.sh                 # pull :latest for all four
#      ./pull-images.sh --all-tags      # also list every remote tag per image
#      ./pull-images.sh --no-prune      # keep dangling <none> images
#      ./pull-images.sh --prune         # prune unused images (default: yes)
#
#  Requirements:
#      - Docker Desktop running
#      - Logged in to the private registry, once:
#            echo "$GITHUB_PAT" | docker login ghcr.io -u <github-user> --password-stdin
#        The PAT needs the `read:packages` scope.
#
#  Overrides (defaults mirror docker-compose/services/*.yml):
#      FRONTEND_IMAGE, BACKEND_IMAGE, AI_BACKEND_IMAGE, BACKOFFICE_IMAGE
#
#  Not Git Bash on Windows? Run it from WSL, or translate the commands by hand.
# =============================================================================
set -euo pipefail

REGISTRY="ghcr.io"
NAMESPACE="hass-top"

FRONTEND_IMAGE="${FRONTEND_IMAGE:-${REGISTRY}/${NAMESPACE}/kidora-frontend:latest}"
BACKEND_IMAGE="${BACKEND_IMAGE:-${REGISTRY}/${NAMESPACE}/kidora-backend:latest}"
AI_BACKEND_IMAGE="${AI_BACKEND_IMAGE:-${REGISTRY}/${NAMESPACE}/kidora-ia-center:latest}"
BACKOFFICE_IMAGE="${BACKOFFICE_IMAGE:-${REGISTRY}/${NAMESPACE}/kidora-backoffice:latest}"

LIST_ALL_TAGS="false"
PRUNE="true"

# Images to pull: name|image-ref
IMAGES=(
  "backend|${BACKEND_IMAGE}"
  "frontend|${FRONTEND_IMAGE}"
  "ai-backend|${AI_BACKEND_IMAGE}"
  "backoffice|${BACKOFFICE_IMAGE}"
)

usage() {
  # Prints the header comment block only - line 2 through the closing `# ====`
  # rule. Keep the end line in sync with the header if you edit it.
  sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all-tags)  LIST_ALL_TAGS="true" ;;
    --prune)     PRUNE="true" ;;
    --no-prune)  PRUNE="false" ;;
    -h|--help)   usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

# --- preflight ---------------------------------------------------------------
command -v docker >/dev/null 2>&1 || {
  echo "ERROR: docker not found in PATH." >&2
  exit 1
}

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: cannot reach the Docker daemon. Is Docker Desktop running?" >&2
  exit 1
fi

# Warn early if we are not logged in - otherwise every pull fails with a 401
# and the real cause is easy to miss.
if ! grep -q "${REGISTRY}" "${DOCKER_CONFIG:-$HOME/.docker}/config.json" 2>/dev/null; then
  cat >&2 <<EOF
WARNING: no stored credentials for ${REGISTRY} found.
The Kidora packages are PRIVATE, so the pulls below will fail with
"unauthorized" until you log in:

    echo "\$GITHUB_PAT" | docker login ${REGISTRY} -u <github-user> --password-stdin

A GitHub PAT with the 'read:packages' scope is required.
EOF
fi

# --- helpers -----------------------------------------------------------------
# Prints the local image ID, or "-" when the image is not present locally.
local_id() {
  docker image inspect "$1" --format '{{.Id}}' 2>/dev/null || echo "-"
}

# --- main --------------------------------------------------------------------
echo "=========================================="
echo "  Kidora - pulling images from GitHub"
echo "=========================================="

FAILED=()

for entry in "${IMAGES[@]}"; do
  IFS='|' read -r name ref <<< "$entry"

  echo ""
  echo "------------------------------------------"
  echo "  ${name}"
  echo "  ${ref}"

  if [[ "$LIST_ALL_TAGS" == "true" ]]; then
    # Requires auth; harmless to skip if the CLI cannot reach the API.
    tags=$(docker manifest inspect "$ref" >/dev/null 2>&1 && echo "  manifest: OK" || echo "  manifest: unavailable (needs auth)")
    echo "  ${tags}"
  fi

  before=$(local_id "$ref")

  if docker pull "$ref"; then
    after=$(local_id "$ref")
    if [[ "$before" == "$after" ]]; then
      echo "  already up to date (${after})"
    else
      echo "  UPDATED: ${before} -> ${after}"
    fi
  else
    echo "  FAILED to pull ${ref}" >&2
    FAILED+=("$name")
  fi
done

if [[ "$PRUNE" == "true" ]]; then
  echo ""
  echo "Pruning dangling (<none>) images..."
  docker image prune -f >/dev/null 2>&1 || echo "  (nothing to prune)"
fi

echo ""
echo "=========================================="
echo "  Local Kidora images"
echo "=========================================="
for entry in "${IMAGES[@]}"; do
  IFS='|' read -r name ref <<< "$entry"
  id=$(local_id "$ref")
  created=$(docker image inspect "$ref" --format '{{.Created}}' 2>/dev/null || true)
  [[ -n "$created" ]] || created="(not present locally)"
  # The name column widens to fit the longest entry ("ai-backend", 10 chars),
  # so all four images stay aligned in the summary below.
  printf '  %-10s %s\n' "$name" "$ref"
  printf '  %-10s id: %-20s built: %s\n' "" "${id:0:19}" "$created"
done

echo ""
if [[ ${#FAILED[@]} -gt 0 ]]; then
  echo "FAILED: ${FAILED[*]}"
  echo ""
  echo "If the errors above are 401/unauthorized, log in first:"
  echo "  echo \"\$GITHUB_PAT\" | docker login ${REGISTRY} -u <user> --password-stdin"
  echo ""
  exit 1
fi

cat <<EOF
Next steps:
  # Full local stack (MongoDB + MinIO + backend + AI + frontend + backoffice):
  cp docker-compose/.env.example docker-compose/.env   # then edit the secrets
  docker compose -f docker-compose/docker-compose.dev.yml up -d

  # Production-shaped split, if that is what you are reproducing:
  docker compose -f docker-compose/docker-compose-infra.yml up -d
  docker compose -f docker-compose/docker-compose-app.yml up -d

See docker-compose/README.md for the full matrix of compose files.

Pin an exact build instead of :latest by exporting e.g.
  BACKEND_IMAGE=${REGISTRY}/${NAMESPACE}/kidora-backend:<sha>
EOF
