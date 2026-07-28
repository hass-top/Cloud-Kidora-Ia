#!/bin/bash
set -e

REGISTRY_VULTR="fra.vultrcr.com"
REGISTRY_LOCAL="localhost:5000"

echo "=========================================="
echo "  Vultr Registry Images & Zot Mapping    "
echo "=========================================="
echo ""

# Check if logged in to Vultr
if ! docker info 2>/dev/null | grep -q "Registry: https://${REGISTRY_VULTR}/v2/"; then
    echo "Not logged in to Vultr registry."
    read -p "Enter Vultr Registry username: " vultr_user
    read -sp "Enter Vultr Registry API key (password): " vultr_pass
    echo ""
    echo "${vultr_pass}" | docker login ${REGISTRY_VULTR} -u "${vultr_user}" --password-stdin
fi

# Get auth token
AUTH_TOKEN=$(curl -s "https://${REGISTRY_VULTR}/v2/token?service=${REGISTRY_VULTR}&scope=repository:kidora/kidora-backend:pull" 2>/dev/null | jq -r '.token' 2>/dev/null)

echo "Images in Vultr Registry (${REGISTRY_VULTR}):"
echo "------------------------------------------"

for repo in "kidora/kidora-backend" "kidora-frontend"; do
    echo ""
    echo "Repository: ${REGISTRY_VULTR}/${repo}"
    
    # Get catalog
    CATALOG=$(curl -s -H "Authorization: Bearer ${AUTH_TOKEN}" "https://${REGISTRY_VULTR}/v2/${repo}/tags/list" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$CATALOG" ]; then
        TAGS=$(echo "$CATALOG" | jq -r '.tags[]' 2>/dev/null)
        if [ -n "$TAGS" ]; then
            echo "  Available tags:"
            echo "$TAGS" | while read -r tag; do
                echo "    - ${tag}"
            done
        else
            echo "  (No tags found)"
        fi
    else
        echo "  (Could not fetch tags - trying with docker pull instead)"
        echo "  Available:"
        echo "    - latest (if accessible)"
    fi
    
    # Determine local Zot name
    case $repo in
        "kidora/kidora-backend")
            LOCAL_NAME="kidora-backend"
            ;;
        "kidora-frontend")
            LOCAL_NAME="kidora-frontend"
            ;;
    esac
    
    echo "  Maps to Zot: ${REGISTRY_LOCAL}/${LOCAL_NAME}:<tag>"
    echo ""
done

echo "=========================================="
echo "  Zot Registry Status (localhost:5000)   "
echo "=========================================="
echo ""

if curl -s http://localhost:5000/v2/ >/dev/null 2>&1; then
    echo "Zot is running. Available images:"
    echo ""
    
    # Get catalog from Zot
    ZOT_CATALOG=$(curl -s http://localhost:5000/v2/_catalog 2>/dev/null)
    if [ -n "$ZOT_CATALOG" ]; then
        echo "$ZOT_CATALOG" | jq -r '.repositories[]' 2>/dev/null | while read -r repo; do
            echo "  - ${repo}"
            TAGS=$(curl -s "http://localhost:5000/v2/${repo}/tags/list" 2>/dev/null | jq -r '.tags[]' 2>/dev/null)
            if [ -n "$TAGS" ]; then
                echo "$TAGS" | while read -r tag; do
                    echo "      - ${tag}"
                done
            fi
        done
    else
        echo "  (Could not fetch catalog)"
    fi
else
    echo "Zot is NOT running or not accessible at localhost:5000"
fi

echo ""
echo "=========================================="
echo "  Usage in docker-compose-app.yml       "
echo "=========================================="
echo ""
echo "To use local Zot images, update service files:"
echo "  Backend: image: ${REGISTRY_LOCAL}/kidora-backend:<tag>"
echo "  Frontend: image: ${REGISTRY_LOCAL}/kidora-frontend:<tag>"
echo ""
echo "Run sync_images.sh to pull from Vultr and push to Zot."