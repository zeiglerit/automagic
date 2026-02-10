#!/usr/bin/env bash
set -euo pipefail

ARGO_NS="argocd"
GITOPS_APPS="./gitops/apps"

echo "=== Uninstalling Helm apps ==="
find "$GITOPS_APPS" -type f -name "values.yaml" -print0 | while IFS= read -r -d '' values; do
  APP_DIR=$(dirname "$values")
  APP_NAME=$(basename "$APP_DIR")

  echo "Uninstalling Helm release: $APP_NAME"
  helm uninstall "$APP_NAME" --namespace "$APP_NAME" || true
done

echo "=== Deleting YAML apps ==="
find "$GITOPS_APPS" -type f -name "*.yaml" -print0 | while IFS= read -r -d '' file; do
  echo "Deleting $file"
  kubectl delete -f "$file" --ignore-not-found
done

echo "=== Removing Argo CD ==="
kubectl delete namespace "$ARGO_NS" --ignore-not-found

echo "=== Cleanup complete ==="
