#!/bin/bash

VULTR_API_KEY="OMFJZHFO6P637XQJKYMIOB3T3B3KYEICDXKA"
REGISTRY_ID="bf547cef-c22f-46c5-87d2-43852d1334e2"

API="https://api.vultr.com/v2"

echo "=== Container Registry Repositories ==="

repositories=$(curl -s \
  -H "Authorization: Bearer $VULTR_API_KEY" \
  "$API/registry/$REGISTRY_ID/repositories")

echo "$repositories" | jq

echo
echo "=== Artifacts ==="

echo "$repositories" | jq -r '.repositories[] | "\(.name)|\(.image)"' | while IFS='|' read -r name image
do
    echo
    echo "Repository: $name"
    echo "Image: $image"

    curl -s \
      -H "Authorization: Bearer $VULTR_API_KEY" \
      "$API/registry/$REGISTRY_ID/repository/$image/artifacts" \
      | jq
done
