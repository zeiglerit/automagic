#!/usr/bin/env bash
set -euo pipefail

ARGO_NS="argocd"
GITOPS_ROOT="./gitops/root"
GITOPS_APPS="./gitops/apps"

echo "=== Installing Argo CD ==="
kubectl create namespace $ARGO_NS --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n $ARGO_NS -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD server to be ready..."
kubectl rollout status deployment/argocd-server -n $ARGO_NS --timeout=300s

echo "=== Applying Root App-of-Apps ==="
kubectl apply -f $GITOPS_ROOT

echo "=== Deploying YAML-based apps ==="
find "$GITOPS_APPS" -type f -name "*.yaml" -print0 | while IFS= read -r -d '' file; do
  echo "Applying $file"
  kubectl apply -f "$file"
done

echo "=== Deploying Helm-based apps ==="
find "$GITOPS_APPS" -type f -name "values.yaml" -print0 | while IFS= read -r -d '' values; do
  APP_DIR=$(dirname "$values")
  APP_NAME=$(basename "$APP_DIR")

  echo "Deploying Helm chart for $APP_NAME"
  helm upgrade --install "$APP_NAME" "$APP_DIR" -f "$values" --namespace "$APP_NAME" --create-namespace
done

echo "=== Deployment complete ==="
