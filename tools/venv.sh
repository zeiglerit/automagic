#!/usr/bin/env bash

# Usage:
#   ./venv.sh <env-name>
#
# Creates a Python virtual environment inside ~/venvs/<env-name>
# and activates it.

set -e

if [ -z "$1" ]; then
    echo "Error: No environment name provided."
    echo "Usage: ./venv.sh <env-name>"
    exit 1
fi

ENV_NAME="$1"
BASE_DIR="$HOME/venvs"
ENV_DIR="$BASE_DIR/$ENV_NAME"

# Ensure base directory exists
mkdir -p "$BASE_DIR"

echo "Creating virtual environment: $ENV_DIR"
python3 -m venv "$ENV_DIR"

echo "Activating environment..."
# shellcheck disable=SC1090
source "$ENV_DIR/bin/activate"

echo "Virtual environment '$ENV_NAME' is now active."
echo "Python: $(which python)"
echo "Pip:    $(which pip)"
