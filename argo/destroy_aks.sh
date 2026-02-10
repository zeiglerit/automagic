#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-aks"
CLUSTER_NAME="my-aks"

echo "Deleting AKS cluster: $CLUSTER_NAME"

az aks delete \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --yes \
  --no-wait

echo "Deleting resource group: $RESOURCE_GROUP"
az group delete \
  --name "$RESOURCE_GROUP" \
  --yes \
  --no-wait

echo "AKS cluster and resource group deletion initiated."
