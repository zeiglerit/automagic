#!/bin/bash

#REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"

green='\033[0;32m'
yellow='\033[1;33m'
red='\033[0;31m'
reset='\033[0m'

CONFIG_PATH="$REPO_ROOT/scripts/insightedge/config.json"
LOG_DIR="$REPO_ROOT/logs"
JUPYTER_PORT=8888
TB_PORT=6006

mkdir -p "$LOG_DIR"

echo -e "${yellow}Step 1: Training InsightEdge model${reset}"
PYTHONPATH="$REPO_ROOT" python "$REPO_ROOT/scripts/insightedge/train.py" --training_config "$CONFIG_PATH" || {
  echo -e "${red}Training failed${reset}"
  exit 1
}
echo -e "${green}Completed 1/4${reset}"

echo -e "${yellow}Step 2: Launching TensorBoard${reset}"
if pgrep -f "tensorboard.*--port $TB_PORT" > /dev/null; then
  echo -e "${green}TensorBoard already running at http://localhost:$TB_PORT${reset}"
else
  nohup tensorboard --logdir "$LOG_DIR" --port $TB_PORT --bind_all > "$LOG_DIR/tensorboard.out" 2>&1 &
  echo -e "${green}TensorBoard started at http://localhost:$TB_PORT${reset}"
fi
echo -e "${green}Completed 2/4${reset}"

echo -e "${yellow}Step 3: Submitting Azure ML job${reset}"
az ml job create --file "$REPO_ROOT/deploy/job.yml" \
  --resource-group your-resource-group \
  --workspace-name your-workspace-name || echo -e "${red}Azure ML job submission failed${reset}"
echo -e "${green}Completed 3/4${reset}"

echo -e "${yellow}Step 4: Launching JupyterLab${reset}"
if pgrep -f "jupyter-lab.*--port=$JUPYTER_PORT" > /dev/null; then
  echo -e "${green}JupyterLab already running at http://localhost:$JUPYTER_PORT${reset}"
else
  nohup jupyter lab --no-browser --ip=127.0.0.1 --port=$JUPYTER_PORT > "$LOG_DIR/jupyter.out" 2>&1 &
  echo -e "${green}JupyterLab started at http://localhost:$JUPYTER_PORT${reset}"
fi
echo -e "${green}Completed 4/4${reset}"

# Optional: auto-open browser (uncomment if desired)
 xdg-open "http://localhost:$JUPYTER_PORT/lab" &  # Linux
 open "http://localhost:$JUPYTER_PORT/lab" &       # macOS
 start "" "http://localhost:$JUPYTER_PORT/lab"     # Windows (Git Bash or WSL)
