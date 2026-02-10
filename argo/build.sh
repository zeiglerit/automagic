#!/usr/bin/env bash
set -euo pipefail

echo "=== Creating AWS EKS Cluster ==="
./create_eks.sh

echo "=== Creating Azure AKS Cluster ==="
./create_aks.sh

echo "=== Deploying Argo CD + GitOps Apps ==="
./deploy_all.sh

echo "=== Build Complete ==="
