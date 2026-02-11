#!/usr/bin/env bash
set -euo pipefail

# Always run from the directory where this script lives
cd "$(dirname "$0")"

APP_NAME="agentic-helpdesk"
APP_DIR="manifests/${APP_NAME}"
ARGO_APP_FILE="argo-apps/${APP_NAME}.yaml"

echo "Creating folder structure..."
mkdir -p "${APP_DIR}"
mkdir -p "argo-apps"

echo "Creating Argo CD Application..."
cat > "${ARGO_APP_FILE}" <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/zeiglerit/automagic.git
    targetRevision: HEAD
    path: manifests/${APP_NAME}
  destination:
    server: https://kubernetes.default.svc
    namespace: ${APP_NAME}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "Creating Deployment..."
cat > "${APP_DIR}/deployment.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
    spec:
      containers:
      - name: vllm
        image: vllm/vllm-openai:latest
        args:
          - "--model"
          - "mistral"
          - "--max-model-len"
          - "8192"
        ports:
        - containerPort: 8000
        env:
        - name: SYSTEM_PROMPT
          valueFrom:
            configMapKeyRef:
              name: ${APP_NAME}-config
              key: system_prompt
EOF

echo "Creating Service..."
cat > "${APP_DIR}/service.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}
spec:
  selector:
    app: ${APP_NAME}
  ports:
  - port: 8000
    targetPort: 8000
EOF

echo "Creating ConfigMap..."
cat > "${APP_DIR}/configmap.yaml" <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${APP_NAME}-config
data:
  system_prompt: |
    You are AgenticHelpdeskAI, an autonomous helpdesk assistant that:
    - Troubleshoots user issues
    - Asks clarifying questions
    - Uses tools when needed
    - Maintains internal reasoning
    - Responds concisely and professionally
    - Improves over time based on user interactions
EOF

echo "Creating Namespace manifest..."
cat > "${APP_DIR}/namespace.yaml" <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ${APP_NAME}
EOF

echo "All files created for ${APP_NAME}."
echo "Commit and push to Git, then Argo CD will deploy automatically."
