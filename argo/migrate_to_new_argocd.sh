#!/usr/bin/env bash
set -euo pipefail

###############################################
# CONFIGURATION
###############################################

ARGO_SERVER="${ARGO_SERVER:-localhost:8080}"
ARGO_USERNAME="${ARGO_USERNAME:-admin}"
DEST_NAMESPACE="argocd"

AWS_REGION="${AWS_REGION:-us-east-1}"

REPO_URL="${REPO_URL:-https://github.com/zeiglerit/automagic.git}"
REPO_PATH_ROOT="$(pwd)"

# Map directory names → actual EKS cluster names
declare -A CLUSTER_MAP=(
  ["helpdesk-llm"]="helpdesk-aws"
)

###############################################
# LOGIN TO ARGO CD
###############################################

echo "🔐 Logging into Argo CD at $ARGO_SERVER ..."

PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d)

argocd login "$ARGO_SERVER" \
  --username "$ARGO_USERNAME" \
  --password "$PASS" \
  --grpc-web \
  --insecure

echo "✔ Logged in"

###############################################
# MIGRATE CLUSTER APPS
###############################################

echo "📁 Scanning clusters directory..."

CLUSTERS_DIR="$REPO_PATH_ROOT/clusters"

if [[ ! -d "$CLUSTERS_DIR" ]]; then
  echo "❌ clusters/ directory not found"
  exit 1
fi

###############################################
# PROCESS EACH CLUSTER
###############################################

find "$CLUSTERS_DIR" -name "app.yaml" | while read -r APP_FILE; do
  DIR_NAME=$(basename "$(dirname "$APP_FILE")")

  # Lookup real EKS cluster name
  CLUSTER_NAME="${CLUSTER_MAP[$DIR_NAME]:-}"

  if [[ -z "$CLUSTER_NAME" ]]; then
    echo "❌ No EKS cluster mapping found for directory: $DIR_NAME"
    exit 1
  fi

  APP_NAME="$DIR_NAME"

  echo "🚀 Processing cluster: $DIR_NAME"
  echo "   → EKS cluster name: $CLUSTER_NAME"
  echo "   → App file: $APP_FILE"

  # Repo path (optional)
  APP_PATH=""

  ###############################################
  # FETCH EKS API SERVER ENDPOINT
  ###############################################

  DEST_SERVER=$(aws eks describe-cluster \
    --name "$CLUSTER_NAME" \
    --region "$AWS_REGION" \
    --query "cluster.endpoint" \
    --output text)

  echo "   → Server: $DEST_SERVER"

  ###############################################
  # CREATE OR UPDATE THE ARGO CD APP
  ###############################################

  echo "📦 Creating/updating Argo CD app: $APP_NAME"

  argocd app create "$APP_NAME" \
    --repo "$REPO_URL" \
    --path "$APP_PATH" \
    --dest-namespace "$DEST_NAMESPACE" \
    --dest-server "$DEST_SERVER" \
    --sync-policy automated \
    --self-heal \
    --auto-prune \
    --upsert

  ###############################################
  # SYNC THE APP
  ###############################################

  echo "🔄 Syncing $APP_NAME ..."
  argocd app sync "$APP_NAME" --prune

  echo "✔ $APP_NAME migrated and synced"
  echo "----------------------------------------"
done

echo "🎉 Migration complete!"
