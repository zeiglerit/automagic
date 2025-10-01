#!/bin/bash

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

RG="automagic-rg"
WS="automagic-workspace"
TARGET="cpu-cluster"
AKS_NAME="automagic-aks"

echo -e "${yellow}Step 1: Stopping local services (JupyterLab, TensorBoard)${reset}"
pkill -f "jupyter-lab" && echo -e "${green}JupyterLab stopped${reset}" || echo -e "${yellow}No JupyterLab process found${reset}"
pkill -f "tensorboard" && echo -e "${green}TensorBoard stopped${reset}" || echo -e "${yellow}No TensorBoard process found${reset}"

echo -e "${yellow}Step 2: Deleting Azure ML compute target '${TARGET}'${reset}"
if az ml compute show --name "$TARGET" --resource-group "$RG" --workspace-name "$WS" &>/dev/null; then
  az ml compute delete --name "$TARGET" --resource-group "$RG" --workspace-name "$WS" --yes && \
  echo -e "${green}Compute target '${TARGET}' deleted${reset}"
else
  echo -e "${yellow}Compute target '${TARGET}' not found${reset}"
fi

echo -e "${yellow}Step 3: Deleting Azure ML workspace '${WS}'${reset}"
if az ml workspace show --name "$WS" --resource-group "$RG" &>/dev/null; then
  az ml workspace delete --name "$WS" --resource-group "$RG" --yes && \
  echo -e "${green}Workspace '${WS}' deleted${reset}"
else
  echo -e "${yellow}Workspace '${WS}' not found${reset}"
fi

echo -e "${yellow}Step 4: Deleting AKS cluster '${AKS_NAME}'${reset}"
if az aks show --name "$AKS_NAME" --resource-group "$RG" &>/dev/null; then
  az aks delete --name "$AKS_NAME" --resource-group "$RG" --yes --no-wait && \
  echo -e "${green}AKS cluster '${AKS_NAME}' deletion initiated${reset}"
else
  echo -e "${yellow}AKS cluster '${AKS_NAME}' not found${reset}"
fi

echo -e "${yellow}Final Step: Deleting resource group '${RG}' and all assets${reset}"
if az group show --name "$RG" &>/dev/null; then
  az group delete --name "$RG" --yes --no-wait && \
  echo -e "${green}Resource group '${RG}' deletion initiated${reset}"
else
  echo -e "${yellow}Resource group '${RG}' not found${reset}"
fi

echo -e "${green}✅ Teardown complete. All resources removed or scheduled for deletion.${reset}"
