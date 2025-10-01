
#!/bin/bash

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

echo -e "${yellow}Step 1: Training WealthView model${reset}"
PYTHONPATH="$REPO_ROOT" python "$REPO_ROOT/scripts/wealthview/train.py" || { echo -e "${red}Training failed${reset}"; exit 1; }
echo -e "${green}Completed 1/4${reset}"

echo -e "${yellow}Step 2: Launching TensorBoard${reset}"
tensorboard --logdir "$REPO_ROOT/logs" --port 6007 --bind_all || echo -e "${red}TensorBoard port in use${reset}"
echo -e "${green}Completed 2/4${reset}"

echo -e "${yellow}Step 3: Submitting Azure ML job${reset}"
az ml job create --file "$REPO_ROOT/deploy/job.yml" \
  --resource-group your-resource-group \
  --workspace-name your-workspace-name || echo -e "${red}Azure ML job submission failed${reset}"
echo -e "${green}Completed 3/4${reset}"

echo -e "${yellow}Step 4: Launching JupyterLab${reset}"
jupyter lab --no-browser --ip=127.0.0.1 --port=8890 || echo -e "${red}JupyterLab failed to launch${reset}"
echo -e "${green}Completed 4/4${reset}"
