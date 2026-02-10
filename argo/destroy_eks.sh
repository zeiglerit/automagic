#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="my-eks"
REGION="us-east-1"

echo "Deleting EKS cluster: $CLUSTER_NAME in $REGION"

eksctl delete cluster \
  --name "$CLUSTER_NAME" \
  --region "$REGION"

echo "EKS cluster deleted."
