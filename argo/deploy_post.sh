#!/bin/bash

echo "Getting Argo CD admin password..."
SECRET=$(kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 -d)

echo "Installing Argo CD CLI..."
curl -sSL -o argocd \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

echo "Logging into Argo CD..."
argocd login localhost:8080 --username admin --password "$SECRET" --insecure
