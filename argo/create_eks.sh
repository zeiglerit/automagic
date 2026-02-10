#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="my-eks"
REGION="us-east-1"
NODE_TYPE="t3.medium"
NODE_COUNT=2

echo "Creating EKS cluster: $CLUSTER_NAME in $REGION"

eksctl create cluster \
  --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --nodegroup-name "standard-workers" \
  --node-type "$NODE_TYPE" \
  --nodes "$NODE_COUNT" \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed

echo "EKS cluster created successfully."
echo "Kubeconfig updated. Context is now: $(kubectl config current-context)"
