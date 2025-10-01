#!/bin/bash

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

CONFIG_PATH="$REPO_ROOT/scripts/insightedge/config.json"

echo -e "${yellow}Step 1/4: Training InsightEdge model${reset}"
PYTHONPATH="$REPO_ROOT" python "$REPO_ROOT/scripts/insightedge/train.py" --training_config "$CONFIG_PATH" || {
  echo -e "${red}Training failed${reset}"
  exit 1
}
echo -e "${green}Completed 1/4${reset}"

echo -e "${yellow}Step 2/4: Launching TensorBoard${reset}"
tensorboard --logdir "$REPO_ROOT/logs" --port 6006 --bind_all || echo -e "${red}TensorBoard port in use${reset}"
echo -e "${green}Completed 2/4${reset}"

echo -e "${yellow}Step 3/4: Submitting Azure ML job${reset}"
az ml job create --file "$REPO_ROOT/deploy/job.yml" \
  --resource-group your-resource-group \
  --workspace-name your-workspace-name || echo -e "${red}Azure ML job submission failed${reset}"
echo -e "${green}Completed 3/4${reset}"

echo -e "${yellow}Step 4/4: Launching JupyterLab${reset}"
jupyter lab --no-browser --ip=127.0.0.1 --port=8888 || echo -e "${red}JupyterLab failed to launch${reset}"
echo -e "${green}Completed 4/4${reset}"
