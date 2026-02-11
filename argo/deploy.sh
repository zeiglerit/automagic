#!/usr/bin/env bash
set -e

AWS_CLUSTER="helpdesk-aws"
AZURE_CLUSTER="helpdesk-azure"

AWS_REGION="us-east-1"
AZURE_RG="helpdesk-rg"
AZURE_LOCATION="eastus"

echo "=============================================="
echo " Checking AWS EKS Cluster"
echo "=============================================="

if eksctl get cluster --name "$AWS_CLUSTER" --region "$AWS_REGION" >/dev/null 2>&1; then
  echo "EKS cluster '$AWS_CLUSTER' already exists. Skipping creation."
else
  echo "Creating EKS cluster '$AWS_CLUSTER'..."
  eksctl create cluster \
    --name "$AWS_CLUSTER" \
    --region "$AWS_REGION" \
    --nodes 2 \
    --version 1.30
fi

echo "Updating kubeconfig for AWS..."
aws eks update-kubeconfig \
  --name "$AWS_CLUSTER" \
  --region "$AWS_REGION"


echo "=============================================="
echo " Checking Azure AKS Cluster"
echo "=============================================="

if az group exists --name "$AZURE_RG"; then
  echo "Azure resource group '$AZURE_RG' already exists."
else
  echo "Creating Azure resource group '$AZURE_RG'..."
  az group create --name "$AZURE_RG" --location "$AZURE_LOCATION"
fi

AKS_EXISTS=$(az aks list --resource-group "$AZURE_RG" --query "[?name=='$AZURE_CLUSTER'] | length(@)")

if [[ "$AKS_EXISTS" -gt 0 ]]; then
  echo "AKS cluster '$AZURE_CLUSTER' already exists. Skipping creation."
else
  echo "Creating AKS cluster '$AZURE_CLUSTER'..."
  az aks create \
    --resource-group "$AZURE_RG" \
    --name "$AZURE_CLUSTER" \
    --node-count 2 \
    --node-vm-size Standard_B4ms \
    --generate-ssh-keys
fi

echo "Fetching kubeconfig for Azure..."
az aks get-credentials \
  --resource-group "$AZURE_RG" \
  --name "$AZURE_CLUSTER" \
  --overwrite-existing


echo "=============================================="
echo " Registering clusters with Argo CD"
echo "=============================================="

AWS_CTX=$(kubectl config get-contexts -o name | grep "$AWS_CLUSTER" | head -n 1)
AZURE_CTX=$(kubectl config get-contexts -o name | grep "$AZURE_CLUSTER" | head -n 1)

echo "AWS context detected:   $AWS_CTX"
echo "Azure context detected: $AZURE_CTX"

# Check if Argo already knows about AWS
if argocd cluster list | grep -q "aws"; then
  echo "Argo CD already has cluster 'aws' registered. Skipping."
else
  echo "Registering AWS cluster with Argo..."
  argocd cluster add "$AWS_CTX" --name aws --yes
fi

# Check if Argo already knows about Azure
if argocd cluster list | grep -q "azure"; then
  echo "Argo CD already has cluster 'azure' registered. Skipping."
else
  echo "Registering Azure cluster with Argo..."
  argocd cluster add "$AZURE_CTX" --name azure --yes
fi

echo "=============================================="
echo " Deploying Argo CD Root App"
echo "=============================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Deploying Argo CD Root App..."
kubectl apply -f "$SCRIPT_DIR/argo-apps/root-app.yaml"

echo "Root app applied. Argo CD will now sync AWS + Azure apps."
echo "=============================================="
echo " Deployment Complete"
echo "=============================================="
