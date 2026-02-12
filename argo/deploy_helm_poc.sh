#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${1:-security-ai}"
CHART_DIR="helm/$APP_NAME"

echo "Scaffolding Helm chart at: $CHART_DIR"

mkdir -p "$CHART_DIR/templates"

cat > "$CHART_DIR/Chart.yaml" <<EOF
apiVersion: v2
name: $APP_NAME
description: A simple AI security model service
type: application
version: 0.1.0
appVersion: "1.0"
EOF

cat > "$CHART_DIR/values.yaml" <<EOF
replicaCount: 1

image:
  repository: nginx
  tag: latest

service:
  type: ClusterIP
  port: 80
EOF

cat > "$CHART_DIR/templates/deployment.yaml" <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "$APP_NAME.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ include "$APP_NAME.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "$APP_NAME.name" . }}
    spec:
      containers:
      - name: $APP_NAME
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: 80
EOF

cat > "$CHART_DIR/templates/service.yaml" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: {{ include "$APP_NAME.fullname" . }}
spec:
  type: {{ .Values.service.type }}
  selector:
    app: {{ include "$APP_NAME.name" . }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: 80
EOF

echo "Helm chart created at $CHART_DIR"
