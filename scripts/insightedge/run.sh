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
RG="automagic-rg"           # ← your real resource group name
WS="automagic-workspace"    # ← your real Azure ML workspace name
TARGET="cpu-cluster"

mkdir -p "$LOG_DIR"

echo -e "${yellow}Step 1: Training InsightEdge model${reset}"
PYTHONPATH="$REPO_ROOT" python "$REPO_ROOT/scripts/insightedge/train.py" --training_config "$CONFIG_PATH" || {
  echo -e "${red}Training failed${reset}"
  exit 1
}
echo -e "${green}Completed 1/4${reset}"

echo -e "${yellow}Step 2: Launching TensorBoard${reset}"
pkill -f "tensorboard.*--port $TB_PORT" && echo -e "${yellow}Killed existing TensorBoard on port $TB_PORT${reset}"

nohup tensorboard --logdir "$LOG_DIR" --port $TB_PORT --bind_all > "$LOG_DIR/tensorboard.out" 2>&1 &
echo -e "${green}TensorBoard started at http://localhost:$TB_PORT${reset}"
echo -e "${green}Completed 2/4${reset}"

echo -e "${yellow}Step 3: Verifying Azure ML compute target${reset}"
if az ml compute show --name "$TARGET" --resource-group "$RG" --workspace-name "$WS" &>/dev/null; then
  echo -e "${green}Compute target '$TARGET' already exists${reset}"
else
  echo -e "${yellow}Creating compute target '$TARGET'${reset}"
  az ml compute create --name "$TARGET" \
    --size Standard_DS3_v2 \
    --type AmlCompute \
    --min-instances 0 \
    --max-instances 2 \
    --resource-group "$RG" \
    --workspace-name "$WS" || {
      echo -e "${red}Failed to create compute target '$TARGET'${reset}"
      exit 1
  }

  echo -e "${yellow}Waiting for compute target '$TARGET' to become available...${reset}"
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

echo -e "${green}All steps completed. Pipeline finished.${reset}"
