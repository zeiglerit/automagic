#!/bin/bash

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

CONFIG_PATH="$REPO_ROOT/scripts/insightedge/config.json"
LOG_DIR="$REPO_ROOT/logs"
JUPYTER_PORT=8888
TB_PORT=6006
RG="automagic-rg"
WS="automagic-workspace"
TARGET="cpu-cluster"
VM_SIZE="Standard_B2s"
LOCATION="eastus"

read -p "Deploy Kubernetes cluster for app? (y/n): " deploy_aks

echo "Checking for pipreqs..."
if ! command -v pipreqs &>/dev/null; then
  echo "Installing pipreqs..."
  pip install pipreqs
fi

mkdir -p "$LOG_DIR"

echo -e "${yellow}Step 1/4: Training InsightEdge model${reset}"
PYTHONPATH="$REPO_ROOT" python "$REPO_ROOT/scripts/insightedge/train.py" --training_config "$CONFIG_PATH" || {
  echo -e "${red}Training failed${reset}"
  exit 1
}
echo -e "${green}Completed 1/4${reset}"

echo -e "${yellow}Step 2/4: Launching TensorBoard${reset}"
pkill -f "tensorboard.*--port $TB_PORT" && echo -e "${yellow}Killed existing TensorBoard on port $TB_PORT${reset}"
nohup tensorboard --logdir "$LOG_DIR" --port $TB_PORT --bind_all > "$LOG_DIR/tensorboard.out" 2>&1 &
echo -e "${green}TensorBoard started at http://localhost:$TB_PORT${reset}"
echo -e "${green}Completed 2/4${reset}"

echo -e "${yellow}Step 3/4: Verifying Azure ML resources${reset}"

echo -e "${yellow}Checking resource group '${RG}'${reset}"
if az group show --name "$RG" &>/dev/null; then
  echo -e "${green}Resource group '$RG' exists${reset}"
else
  az group create --name "$RG" --location "$LOCATION" && \
  echo -e "${green}Resource group '$RG' created${reset}"
fi

echo -e "${yellow}Checking workspace '${WS}'${reset}"
if az ml workspace show --name "$WS" --resource-group "$RG" &>/dev/null; then
  echo -e "${green}Workspace '$WS' exists${reset}"
else
  az ml workspace create --name "$WS" --resource-group "$RG" --location "$LOCATION" && \
  echo -e "${green}Workspace '$WS' created${reset}"
fi

echo -e "${yellow}Checking compute target '${TARGET}'${reset}"
if az ml compute show --name "$TARGET" --resource-group "$RG" --workspace-name "$WS" &>/dev/null; then
  echo -e "${green}Compute target '$TARGET' exists${reset}"
else
  az ml compute create --name "$TARGET" \
    --size "$VM_SIZE" \
    --type AmlCompute \
    --min-instances 0 \
    --max-instances 2 \
    --resource-group "$RG" \
    --workspace-name "$WS" || {
      echo -e "${red}Failed to create compute target '$TARGET'${reset}"
      exit 1
  }

  echo -e "${yellow}Waiting for compute target '${TARGET}' to become available...${reset}"
  while true; do
    STATUS=$(az ml compute show --name "$TARGET" --resource-group "$RG" --workspace-name "$WS" --query "provisioning_state" -o tsv)
    if [[ "$STATUS" == "Succeeded" ]]; then
      echo -e "${green}Compute target '$TARGET' is ready${reset}"
      break
    fi
    echo -e "${yellow}Status: $STATUS. Retrying in 10s...${reset}"
    sleep 10
  done
fi

echo -e "${yellow}Submitting Azure ML job${reset}"
az ml job create --file "$REPO_ROOT/deploy/job.yml" \
  --resource-group "$RG" \
  --workspace-name "$WS" || echo -e "${red}Azure ML job submission failed${reset}"
echo -e "${green}Completed 3/4${reset}"

echo -e "${yellow}Step 4/4: Launching JupyterLab${reset}"
pkill -f "jupyter-lab.*--port=$JUPYTER_PORT" && echo -e "${yellow}Killed existing JupyterLab on port $JUPYTER_PORT${reset}"
nohup jupyter lab --no-browser --ip=127.0.0.1 --port=$JUPYTER_PORT > "$LOG_DIR/jupyter.out" 2>&1 &
echo -e "${green}JupyterLab started at http://localhost:$JUPYTER_PORT${reset}"
echo -e "${green}Completed 4/4${reset}"

if [[ "$deploy_aks" =~ ^[Yy]$ ]]; then
  "$REPO_ROOT/docker/insightedge/deploy_aks.sh"

  echo "AKS cluster deployed and job submitted"
  echo "Checking job and pod status..."

  kubectl get jobs
  kubectl get pods --selector=job-name=insightedge-train
else
  echo " AKS deployment skipped"
fi

echo -e "${green}✅ All steps completed. Pipeline finished.${reset}"
