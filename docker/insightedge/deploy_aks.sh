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
IMAGE_NAME="insightedge-train:latest"
K8S_JOB_PATH="$REPO_ROOT/k8s/train-job.yaml"
LOCATION="eastus"
VM_SIZE="Standard_B2s"         # Quota-safe: 2 vCPUs
NODE_COUNT=1                   # Stay within 2 vCPU quota
MAX_SURGE="0"                  # Avoid surge node overhead
K8S_VERSION="1.33.3"           # Latest supported version

echo -e "${yellow}Step 1: Provisioning AKS cluster '${AKS_NAME}'${reset}"
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

echo -e "${yellow}Step 2: Attaching ACR '${ACR_NAME}' to AKS${reset}"
az aks update \
  --name "$AKS_NAME" \
  --resource-group "$RG" \
  --attach-acr "$ACR_NAME"
echo -e "${green}ACR attached to AKS${reset}"

echo -e "${yellow}Step 3: Getting AKS credentials${reset}"
az aks get-credentials --resource-group "$RG" --name "$AKS_NAME" --overwrite-existing
echo -e "${green}Kubeconfig updated${reset}"

echo -e "${yellow}Step 4: Deploying Kubernetes job${reset}"
kubectl apply -f "$K8S_JOB_PATH"
echo -e "${green}Job submitted to AKS${reset}"

echo -e "${yellow}Step 5: Monitoring job status${reset}"
kubectl get jobs
kubectl get pods --selector=job-name=insightedge-train

echo -e "${green}✅ AKS deployment complete${reset}"
