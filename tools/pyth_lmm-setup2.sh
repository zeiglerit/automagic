#!/bin/bash

# Exit on error
set -e

echo "�� Installing Ollama for local LLM inference..."
curl -fsSL https://ollama.ai/install.sh | bash

echo "📥 Pulling LLaMA 3 model (ideal for chatbot-style interaction)..."
ollama pull llama3

echo "🐍 Activating Conda environment..."
source ~/miniconda/bin/activate llm-env

echo "📦 Installing Python packages for LLM interaction, fine-tuning prep, and MLOps/data science workflows..."
pip install --upgrade pip

# Core LLM tools
pip install transformers datasets accelerate peft bitsandbytes sentencepiece

# Chatbot and orchestration tools
pip install langchain ollama fastapi uvicorn

# MLOps and data science tools
pip install scikit-learn pandas numpy matplotlib seaborn mlflow

echo "✅ Environment setup complete. You're ready to build your chatbot and explore network security, MLOps, and data science workflows."
