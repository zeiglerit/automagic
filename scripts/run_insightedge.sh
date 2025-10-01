#!/bin/bash

echo "Step 1: Training InsightEdge model"
python scripts/insightedge/train.py
echo "Completed 1/4"

echo "Step 2: Launching TensorBoard"
tensorboard --logdir logs --port 6006 &
echo "Completed 2/4"

echo "Step 3: Submitting Azure ML job"
az ml job create --file deploy/job.yml
echo "Completed 3/4"

echo "Step 4: Launching JupyterLab"
jupyter lab --no-browser --ip=127.0.0.1 --port=8888
echo "Completed 4/4"
