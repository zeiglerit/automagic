#!/usr/bin/env bash
set -euo pipefail

ARGO_NS="argocd"
ARGO_HELM_REPO="https://argoproj.github.io/argo-helm"
ARGO_CHART="argo-cd"
ARGO_RELEASE="argo-cd"

OLD_MANIFEST_DIRS=(
  "./argo-apps"
  "./gitops/root"
  "./gitops/apps"
)

echo "=== Adding Argo Helm repo ==="
helm repo add argo "$ARGO_HELM_REPO"
helm repo update

echo "=== Ensuring namespace $ARGO_NS exists ==="
kubectl get ns "$ARGO_NS" >/dev/null 2>&1 || kubectl create namespace "$ARGO_NS"

echo "=== Installing Argo CD via Helm ==="
helm upgrade --install "$ARGO_RELEASE" argo/"$ARGO_CHART" \
  --namespace "$ARGO_NS" \
  --values argo-vars.yaml

echo "=== Helm deployment complete ==="

echo "=== Renaming old Argo CD Kubernetes manifests ==="
for dir in "${OLD_MANIFEST_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    echo "Renaming $dir → $dir.old"
    mv "$dir" "$dir.old"
  else
    echo "Skipping $dir (not found)"
  fi
done

echo "=== Migration complete: Argo CD is now deployed via Helm ==="
