#!/usr/bin/env bash
set -euo pipefail

MODEL="x/z-image-turbo"
MIN_VERSION="0.3.0"   # minimum version required for image generation

usage() {
  echo "Usage: $0 \"your prompt here\""
  exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

PROMPT="$1"

# -----------------------------
# Function: compare versions
# -----------------------------
version_lt() {
  # returns 0 if $1 < $2
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

# -----------------------------
# Ensure Ollama is installed
# -----------------------------
if ! command -v ollama >/dev/null 2>&1; then
  echo "Ollama not found. Installing..."
  curl -fsSL https://ollama.com/install.sh | sh
fi

# -----------------------------
# Check Ollama version
# -----------------------------
CURRENT_VERSION=$(ollama --version | awk '{print $3}')

echo "Detected Ollama version: $CURRENT_VERSION"

if version_lt "$CURRENT_VERSION" "$MIN_VERSION"; then
  echo "Ollama is outdated. Upgrading..."
  pkill ollama || true
  curl -fsSL https://ollama.com/install.sh | sh
  echo "Upgrade complete."
fi

# -----------------------------
# Start Ollama server if needed
# -----------------------------
if ! pgrep -x "ollama" >/dev/null; then
  echo "Starting Ollama server..."
  nohup ollama serve >/dev/null 2>&1 &
  sleep 3
fi

# -----------------------------
# Pull the model
# -----------------------------
echo "Pulling model: $MODEL"
ollama pull "$MODEL"

# -----------------------------
# Generate image
# -----------------------------
echo "Generating image..."
OUTPUT_DIR="./ollama_images"
mkdir -p "$OUTPUT_DIR"

(
  cd "$OUTPUT_DIR"
  ollama run "$MODEL" "$PROMPT"
)

echo "Done. Images saved in: $OUTPUT_DIR"
