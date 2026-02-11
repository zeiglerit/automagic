#!/usr/bin/env bash

set -e

# === CONFIG ===
REPO_URL="https://github.com/zeiglerit/automagic.git"
BRANCH="master"
APP_NAME="agentic-helpdesk"
MANIFEST_PATH="manifests/${APP_NAME}"
ARGO_APPS_DIR="argo-apps"

# List your cluster names here (as registered in Argo CD)
CLUSTERS=("cluster1" "cluster2" "cluster3")

echo "Creating directory structure..."

mkdir -p "${MANIFEST_PATH}"
mkdir -p "${ARGO_APPS_DIR}"

# === ROOT APP ===
cat > "${ARGO_APPS_DIR}/root-app.yaml" <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${BRANCH}
    path: ${ARGO_APPS_DIR}
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "Created root-app.yaml"

# === CHILD APPS (one per cluster) ===
for CLUSTER in "${CLUSTERS[@]}"; do
  APP_FILE="${ARGO_APPS_DIR}/${APP_NAME}-${CLUSTER}.yaml"

  cat > "${APP_FILE}" <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}-${CLUSTER}
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${BRANCH}
    path: ${MANIFEST_PATH}
  destination:
    name: ${CLUSTER}
    namespace: ${APP_NAME}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

  echo "Created ${APP_FILE}"
done

echo "All Argo CD app files generated successfully."
echo "Now commit + push, then sync root-app in Argo."
