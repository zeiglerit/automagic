#!/bin/bash

# Exit on error
set -e

echo "�� Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "🐍 Installing Miniconda..."
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda
rm ~/miniconda.sh

# Add conda to PATH
export PATH="$HOME/miniconda/bin:$PATH"
echo 'export PATH="$HOME/miniconda/bin:$PATH"' >> ~/.bashrc

echo "📦 Updating Conda and creating Python environment..."
conda init bash
source ~/.bashrc
conda update -n base -c defaults conda -y
conda create -n llm-env python=3.10 -y
conda activate llm-env

echo "🧰 Installing system dependencies for AI Toolkit and Python packages..."
sudo apt install -y build-essential libssl-dev libffi-dev python3-dev

echo "✅ Setup complete. Miniconda installed and Python environment 'llm-env' is ready."
