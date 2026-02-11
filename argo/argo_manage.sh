#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------
# Set your Git repo URL here
# ---------------------------------------------------------
GIT_URL="https://github.com/zeiglerit/automagic.git"   # <-- replace this ONCE with your real repo URL

if [[ "$GIT_URL" == "<giturl>" ]]; then
  echo "ERROR: Please edit argo_manage.sh and set GIT_URL to your repo URL"
  exit 1
fi

# ---------------------------------------------------------
# Fixed values
# ---------------------------------------------------------
CLUSTER_NAME="helpdesk-llm"
REGION="us-central"
NAMESPACE="argocd"
ROOT_APP_NAME="root-app"
REPO_PATH_ROOT="argo-apps"
REPO_PATH_CLUSTER="clusters/${CLUSTER_NAME}"

mkdir -p argo-apps
mkdir -p clusters/${CLUSTER_NAME}

# ---------------------------------------------------------
# Generate argo-vars.yaml (optional but useful)
# ---------------------------------------------------------
cat > argo-vars.yaml <<EOF
gitUrl: "${GIT_URL}"
clusterName: "${CLUSTER_NAME}"
region: "${REGION}"
rootPath: "${REPO_PATH_ROOT}"
clusterPath: "${REPO_PATH_CLUSTER}"
EOF

echo "Generated argo-vars.yaml"

# ---------------------------------------------------------
# Generate root-app.yaml
# ---------------------------------------------------------
cat > argo-apps/root-app.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${ROOT_APP_NAME}
  namespace: ${NAMESPACE}
spec:
  project: default
  source:
    repoURL: ${GIT_URL}
    targetRevision: HEAD
    path: ${REPO_PATH_ROOT}
  destination:
    server: https://kubernetes.default.svc
    namespace: ${NAMESPACE}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# ---------------------------------------------------------
# Generate cloud-specific apps (aws, azure, gcp)
# ---------------------------------------------------------
for CLOUD in aws azure gcp; do
cat > argo-apps/${CLOUD}-app.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${CLUSTER_NAME}-${CLOUD}
  namespace: ${NAMESPACE}
spec:
  project: default
  source:
    repoURL: ${GIT_URL}
    targetRevision: HEAD
    path: manifests/${CLOUD}
  destination:
    name: ${CLOUD}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF
done

# ---------------------------------------------------------
# Generate cluster app
# ---------------------------------------------------------
cat > clusters/${CLUSTER_NAME}/app.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${CLUSTER_NAME}-cluster
  namespace: ${NAMESPACE}
spec:
  project: default
  source:
    repoURL: ${GIT_URL}
    targetRevision: HEAD
    path: ${REPO_PATH_CLUSTER}
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "All Argo CD files generated successfully."
echo "Apply with: kubectl apply -f argo-apps/root-app.yaml"
