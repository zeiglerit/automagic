#!/bin/bash

set -e

# Location of your Argo CD cluster manifests
CLUSTER_DIR="clusters/helpdesk-llm"

# List of Argo CD Application manifests to deploy
APPS=(
  "nginx-webserver.yaml"
  "fastapi-backend.yaml"
  "redis-store.yaml"
)

echo "=== Deploying Argo CD Applications ==="

for app in "${APPS[@]}"; do
    FILE="$CLUSTER_DIR/$app"

    if [[ ! -f "$FILE" ]]; then
        echo "Skipping missing file: $FILE"
        continue
    fi

    echo "Applying: $FILE"
    kubectl apply -f "$FILE"
done

echo "=== Creating namespaces for each app ==="

# Namespaces must match the ones in your Argo CD Application specs
NAMESPACES=(
  "nginx-webserver"
  "fastapi-backend"
  "redis-store"
)

for ns in "${NAMESPACES[@]}"; do
    echo "Ensuring namespace exists: $ns"
    kubectl get ns "$ns" >/dev/null 2>&1 || kubectl create ns "$ns"
done

echo "=== Done. Argo CD will now sync the apps. ==="
echo "Check Argo CD UI or run:"
echo "  kubectl get applications -n argocd"
