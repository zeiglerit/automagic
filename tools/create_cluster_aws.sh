#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================
CLUSTER_NAME="eks-prod"
REGION="us-east-1"
NODE_TYPE="t3.medium"
NODE_COUNT=2

# ==========================================
# MODE HANDLING
# ==========================================
if [[ "$1" == "--mode" && "$2" == "c" ]]; then
    echo "=== Creating EKS cluster: $CLUSTER_NAME ==="

    eksctl create cluster \
      --name $CLUSTER_NAME \
      --region $REGION \
      --nodes $NODE_COUNT \
      --node-type $NODE_TYPE \
      --managed

    echo "Cluster created. Current kube contexts:"
    kubectl config get-contexts

elif [[ "$1" == "--mode" && "$2" == "d" ]]; then
    echo "=== Destroying EKS cluster: $CLUSTER_NAME ==="

    eksctl delete cluster \
      --name $CLUSTER_NAME \
      --region $REGION

    echo "Cluster destroyed."

else
    echo "Usage:"
    echo "  $0 --mode c    # create cluster"
    echo "  $0 --mode d    # destroy cluster"
    exit 1
fi
