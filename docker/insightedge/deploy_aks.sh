#!/bin/bash

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

RG="automagic-rg"
AKS_NAME="automagic-aks"
ACR_NAME="automagicacr"
IMAGE_NAME="insightedge-train"
IMAGE_TAG="latest"
LOCATION="eastus"
VM_SIZE="Standard_B2s"
NODE_COUNT=1
K8S_VERSION="1.33.3"
K8S_JOB_PATH="$REPO_ROOT/k8s/train-job.yaml"
DOCKER_CONTEXT="$REPO_ROOT"

echo -e "${yellow}Step 1: Creating resource group '${RG}' if missing${reset}"
az group show --name "$RG" &>/dev/null || az group create --name "$RG" --location "$LOCATION"

echo -e "${yellow}Step 2: Creating ACR '${ACR_NAME}' if missing${reset}"
if az acr show --name "$ACR_NAME" --resource-group "$RG" &>/dev/null; then
  echo -e "${green}ACR '$ACR_NAME' already exists${reset}"
else
  az acr create \
    --name "$ACR_NAME" \
    --resource-group "$RG" \
    --sku Basic \
    --location "$LOCATION" \
    --admin-enabled true
  echo -e "${green}ACR '$ACR_NAME' created${reset}"
fi

echo -e "${yellow}Step 3: Building and pushing Docker image via ACR${reset}"
az acr build \
  --registry "$ACR_NAME" \
  --image "$IMAGE_NAME:$IMAGE_TAG" \
  "$REPO_ROOT"
echo -e "${green}Image built and pushed via ACR${reset}"

echo -e "${yellow}Step 4: Provisioning AKS cluster '${AKS_NAME}'${reset}"
if az aks show --name "$AKS_NAME" --resource-group "$RG" &>/dev/null; then
  echo -e "${green}AKS cluster '${AKS_NAME}' already exists${reset}"
else
  az aks create \
    --resource-group "$RG" \
    --name "$AKS_NAME" \
    --node-vm-size "$VM_SIZE" \
    --node-count "$NODE_COUNT" \
    --kubernetes-version "$K8S_VERSION" \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --location "$LOCATION"
  echo -e "${green}AKS cluster '${AKS_NAME}' created${reset}"
fi

echo -e "${yellow}Step 5: Attaching ACR to AKS${reset}"
az aks update \
  --name "$AKS_NAME" \
  --resource-group "$RG" \
  --attach-acr "$ACR_NAME"
echo -e "${green}ACR attached to AKS${reset}"

echo -e "${yellow}Step 6: Getting AKS credentials${reset}"
az aks get-credentials --resource-group "$RG" --name "$AKS_NAME" --overwrite-existing
echo -e "${green}Kubeconfig updated${reset}"

echo -e "${yellow}Step 7: Deploying Kubernetes job${reset}"
kubectl apply -f "$K8S_JOB_PATH"
echo -e "${green}Job submitted to AKS${reset}"

echo -e "${yellow}Step 8: Monitoring job status${reset}"
kubectl get jobs
kubectl get pods --selector=job-name=insightedge-train

echo -e "${green}✅ AKS deployment complete${reset}"
