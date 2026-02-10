#!/usr/bin/env bash
set -e

APP_NAME="helpdesk-llm"
BASE_DIR="./${APP_NAME}"

echo "Scaffolding Kubernetes + Argo CD structure for ${APP_NAME}"

# -----------------------------
# Create directory structure
# -----------------------------
mkdir -p ${BASE_DIR}/{argo-apps,manifests,clusters}
mkdir -p ${BASE_DIR}/manifests/{aws,azure,gcp}
mkdir -p ${BASE_DIR}/clusters/{aws,azure,gcp}

# -----------------------------
# Argo CD Root App (App of Apps)
# -----------------------------
cat <<EOF > ${BASE_DIR}/argo-apps/root-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}-root
spec:
  project: default
  source:
    repoURL: REPLACE_WITH_GIT_URL
    path: argo-apps
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
  syncPolicy:
    automated: {}
EOF

# -----------------------------
# Argo CD Cloud Apps
# -----------------------------
for CLOUD in aws azure gcp; do
cat <<EOF > ${BASE_DIR}/argo-apps/${CLOUD}-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${APP_NAME}-${CLOUD}
spec:
  project: default
  source:
    repoURL: REPLACE_WITH_GIT_URL
    path: manifests/${CLOUD}
    targetRevision: HEAD
  destination:
    name: ${CLOUD}
  syncPolicy:
    automated: {}
EOF
done

# -----------------------------
# Kubernetes Manifests Per Cloud
# -----------------------------
for CLOUD in aws azure gcp; do

# Deployment
cat <<EOF > ${BASE_DIR}/manifests/${CLOUD}/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APP_NAME}
  labels:
    app: ${APP_NAME}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
    spec:
      containers:
      - name: ${APP_NAME}
        image: REPLACE_WITH_IMAGE
        ports:
        - containerPort: 8080
        env:
        - name: CLOUD_PROVIDER
          value: "${CLOUD}"
        - name: MODEL_NAME
          value: "helpdesk-llm"
EOF

# Service
cat <<EOF > ${BASE_DIR}/manifests/${CLOUD}/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: ${APP_NAME}
spec:
  type: LoadBalancer
  selector:
    app: ${APP_NAME}
  ports:
  - port: 80
    targetPort: 8080
EOF

# Ingress placeholder
cat <<EOF > ${BASE_DIR}/manifests/${CLOUD}/ingress.yaml
# Optional ingress for ${CLOUD}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${APP_NAME}-ingress
spec:
  rules:
  - host: REPLACE_WITH_${CLOUD^^}_DOMAIN
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ${APP_NAME}
            port:
              number: 80
EOF

# Kubeconfig placeholder
cat <<EOF > ${BASE_DIR}/clusters/${CLOUD}/kubeconfig.yaml
# Replace this with the kubeconfig for the ${CLOUD} cluster
EOF

done

echo "Scaffold complete at: ${BASE_DIR}"
