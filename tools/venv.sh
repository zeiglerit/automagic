#!/usr/bin/env bash

# Usage:
#   ./venv.sh myenv
#
# Creates a Python virtual environment with the given name
# and activates it.

set -e

if [ -z "$1" ]; then
    echo "Error: No environment name provided."
    echo "Usage: ./venv.sh <env-name>"
    exit 1
fi

ENV_NAME="$1"

echo "Creating virtual environment: $ENV_NAME"
python3 -m venv "$ENV_NAME"

echo "Activating environment..."
# shellcheck disable=SC1090
source "$ENV_NAME/bin/activate"

echo "Virtual environment '$ENV_NAME' is now active."
echo "Python: $(which python)"
echo "Pip:    $(which pip)"
