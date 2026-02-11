#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------
MODE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$MODE" ]]; then
  echo "Usage: ./deploy.sh --mode [c|d]"
  echo "  c = create"
  echo "  d = destroy"
  exit 1
fi

# ---------------------------------------------------------
# Set your Git repo URL here
# ---------------------------------------------------------
GIT_URL="https://github.com/zeiglerit/automagic.git"   # <-- replace this ONCE with your real repo URL

if [[ "$GIT_URL" == "<giturl>" ]]; then
  echo "ERROR: Please edit deploy.sh and set GIT_URL to your repo URL"
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

# ---------------------------------------------------------
# CREATE MODE
# ---------------------------------------------------------
if [[ "$MODE" == "c" ]]; then
  echo "=== CREATE MODE ==="

  mkdir -p argo-apps
  mkdir -p clusters/${CLUSTER_NAME}

  # -------------------------------------------------------
  # Generate argo-vars.yaml
  # -------------------------------------------------------
  cat > argo-vars.yaml <<EOF
gitUrl: "${GIT_URL}"
clusterName: "${CLUSTER_NAME}"
region: "${REGION}"
rootPath: "${REPO_PATH_ROOT}"
clusterPath: "${REPO_PATH_CLUSTER}"
EOF

  echo "Generated argo-vars.yaml"

  # -------------------------------------------------------
  # Generate root-app.yaml
  # -------------------------------------------------------
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

  # -------------------------------------------------------
  # Generate cloud-specific apps
  # -------------------------------------------------------
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

  # -------------------------------------------------------
  # Generate cluster app
  # -------------------------------------------------------
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

  echo "Generated all Argo CD application files."


  # port forward
  kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &

  # ---------------------------------------------------------
  # Auto-detect kube context for Argo CD registration
  # ---------------------------------------------------------
  CLUSTER_NAME=$(kubectl config current-context)
  echo "Using kube context: $CLUSTER_NAME"

  # -------------------------------------------------------
  # Register cluster with Argo CD
  # -------------------------------------------------------
  echo "Starting Argo CD port-forward..."
  kubectl port-forward svc/argocd-server -n argocd 8080:443 >/dev/null 2>&1 &
  sleep 5

  echo "Logging into Argo CD..."
  argocd login localhost:8080 \
    --username admin \
    --password "$(kubectl -n argocd get secret argocd-initial-admin-secret \
      -o jsonpath='{.data.password}' | base64 -d)" \
    --insecure

  echo "Registering cluster with Argo CD..."
  argocd cluster add "${CLUSTER_NAME}" --yes

  # -------------------------------------------------------
  # Apply root app
  # -------------------------------------------------------
  echo "Applying root Argo CD application..."
  kubectl apply -f argo-apps/root-app.yaml

  echo "Cluster bootstrap complete."
  exit 0
fi

# ---------------------------------------------------------
# DESTROY MODE
# ---------------------------------------------------------
if [[ "$MODE" == "d" ]]; then
  echo "=== DESTROY MODE ==="

  echo "Deleting Argo CD Applications..."
  kubectl delete -f argo-apps/root-app.yaml --ignore-not-found

  echo "Unregistering cluster from Argo CD..."
  argocd cluster rm "${CLUSTER_NAME}" || true

  echo "Cleaning generated files..."
  rm -f argo-vars.yaml
  rm -f argo-apps/*.yaml
  rm -f clusters/${CLUSTER_NAME}/app.yaml

  echo "Destroy complete."
  exit 0
fi
