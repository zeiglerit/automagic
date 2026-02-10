#!/bin/bash
set -e

echo "=== Setting up App-of-Apps GitOps structure ==="

BASE_DIR="gitops"
mkdir -p $BASE_DIR/apps/dev
mkdir -p $BASE_DIR/apps/prod
mkdir -p $BASE_DIR/root

echo "=== Creating child apps (dev + prod) ==="

# Dev app
cat <<EOF > $BASE_DIR/apps/dev/guestbook-dev.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    path: guestbook
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# Prod app
cat <<EOF > $BASE_DIR/apps/prod/guestbook-prod.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    path: guestbook
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "=== Creating root App-of-Apps manifest ==="

cat <<EOF > $BASE_DIR/root/root-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your/repo.git
    path: gitops/apps
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "=== Creating namespaces ==="
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

echo "=== Applying root app ==="
kubectl apply -f $BASE_DIR/root/root-app.yaml

echo "=== Syncing root app ==="
argocd app sync root-app --insecure

echo "=== DONE ==="
echo "App-of-Apps structure deployed and syncing."
