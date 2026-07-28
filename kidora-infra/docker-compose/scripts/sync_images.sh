#!/bin/bash
set -e

REGISTRY_VULTR="fra.vultrcr.com"
REGISTRY_LOCAL="localhost:5000"

# Image configurations: name|vultr_path|local_name
IMAGES=(
    "backend|kidora/kidora-backend|kidora-backend"
    "frontend|kidora-frontend|kidora-frontend"
)

echo "=========================================="
echo "  Kidora Image Sync: Vultr → Local Zot  "
echo "=========================================="
echo ""
echo "Select image to sync:"
echo "1) Backend"
echo "2) Frontend"
echo "3) Both"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
    1) SELECTED=("backend");;
    2) SELECTED=("frontend");;
    3) SELECTED=("backend" "frontend");;
    *) echo "Invalid choice"; exit 1;;
esac

# Check if logged in to Vultr registry
if ! docker info 2>/dev/null | grep -q "Registry: https://${REGISTRY_VULTR}/v2/"; then
    echo ""
    echo "Not logged in to Vultr registry."
    read -p "Enter Vultr Registry username: " vultr_user
    read -sp "Enter Vultr Registry API key (password): " vultr_pass
    echo ""
    echo "${vultr_pass}" | docker login ${REGISTRY_VULTR} -u "${vultr_user}" --password-stdin
fi

echo ""
echo "Fetching available tags from Vultr registry..."
echo ""

for img_key in "${SELECTED[@]}"; do
    # Find image config
    for img in "${IMAGES[@]}"; do
        IFS='|' read -r name vultr_path local_name <<< "$img"
        if [ "$name" == "$img_key" ]; then
            IMG_VULTR="${REGISTRY_VULTR}/${vultr_path}"
            IMG_LOCAL="${REGISTRY_LOCAL}/${local_name}"
            break 2
        fi
    done

    echo "------------------------------------------"
    echo "Image: ${name}"
    echo "Vultr: ${IMG_VULTR}"
    echo ""

    # List tags using Docker Registry HTTP API
    echo "Available tags:"
    if docker pull "${IMG_VULTR}:latest" >/dev/null 2>&1; then
        echo "  latest"
    fi

    # Try to fetch tag list via registry API (requires auth)
    AUTH_TOKEN=$(curl -s "https://${REGISTRY_VULTR}/v2/token?service=${REGISTRY_VULTR}&scope=repository:${vultr_path}:pull" 2>/dev/null | jq -r '.token' 2>/dev/null)
    if [ -n "$AUTH_TOKEN" ] && [ "$AUTH_TOKEN" != "null" ]; then
        TAGS=$(curl -s -H "Authorization: Bearer ${AUTH_TOKEN}" "https://${REGISTRY_VULTR}/v2/${vultr_path}/tags/list" | jq -r '.tags[]' 2>/dev/null)
        if [ -n "$TAGS" ]; then
            echo "$TAGS" | while read -r tag; do
                echo "  ${tag}"
            done
            echo ""
            read -p "Enter tag to pull (default: latest): " selected_tag
            selected_tag=${selected_tag:-latest}
        else
            selected_tag="latest"
        fi
    else
        echo "  (Could not fetch tag list, using 'latest')"
        selected_tag="latest"
    fi

    echo ""
    echo "Pulling ${IMG_VULTR}:${selected_tag}..."
    docker pull "${IMG_VULTR}:${selected_tag}"

    echo ""
    echo "Tagging as ${IMG_LOCAL}:${selected_tag}..."
    docker tag "${IMG_VULTR}:${selected_tag}" "${IMG_LOCAL}:${selected_tag}"

    echo ""
    echo "Pushing to local Zot registry..."
    docker push "${IMG_LOCAL}:${selected_tag}"

    echo ""
    echo "✓ ${name} image synced successfully!"
    echo "  Source: ${IMG_VULTR}:${selected_tag}"
    echo "  Target: ${IMG_LOCAL}:${selected_tag}"
    echo ""

    # Ask if user wants to update docker-compose file
    read -p "Update docker-compose service file for ${name}? [Y/n]: " update_confirm
    if [[ ! "$update_confirm" =~ ^[Nn]$ ]]; then
        SERVICE_FILE="/home/snofy/Desktop/tunis_stage/infra/Cloud-Kidora-Ia/kidora-infra/docker-compose/services"
        case $name in
            backend)
                SERVICE_FILE="${SERVICE_FILE}/04-backend.yml"
                IMAGE_KEY="kidora-backend"
                ;;
            frontend)
                SERVICE_FILE="${SERVICE_FILE}/06-frontend.yml"
                IMAGE_KEY="kidora-frontend"
                ;;
        esac

        if [ -f "$SERVICE_FILE" ]; then
            sed -i "s|image:.*${REGISTRY_VULTR}.*|image: ${REGISTRY_LOCAL}/${IMAGE_KEY}:${selected_tag}|" "$SERVICE_FILE"
            echo "✓ Updated ${SERVICE_FILE}"
        else
            echo "✗ Service file not found: ${SERVICE_FILE}"
        fi
    fi
    echo ""
done

echo "=========================================="
echo "  Sync Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Review the updated service files"
echo "  2. Deploy with: docker compose -f docker-compose-app.yml -p docker-compose-app up -d"