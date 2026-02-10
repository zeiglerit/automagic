#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-aks"
CLUSTER_NAME="my-aks"
LOCATION="eastus"
NODE_SIZE="Standard_DS2_v2"
NODE_COUNT=2

echo "Creating Azure resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

echo "Creating AKS cluster: $CLUSTER_NAME"
az aks create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --node-count "$NODE_COUNT" \
  --node-vm-size "$NODE_SIZE" \
  --generate-ssh-keys

echo "Getting AKS credentials..."
az aks get-credentials \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME"

echo "AKS cluster created successfully."
echo "Kubeconfig updated. Context is now: $(kubectl config current-context)"
