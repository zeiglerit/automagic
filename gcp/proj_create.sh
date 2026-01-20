#!/usr/bin/env bash

set -euo pipefail

PROJECT_NAME=""
DEFAULT_FLAG="no"

usage() {
  echo "Usage: $0 --name <project-id> [-d yes|no]"
  exit 1
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      PROJECT_NAME="$2"
      shift 2
      ;;
    -d)
      DEFAULT_FLAG="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -z "$PROJECT_NAME" ]]; then
  echo "Error: --name is required"
  usage
fi

if [[ "$DEFAULT_FLAG" != "yes" && "$DEFAULT_FLAG" != "no" ]]; then
  echo "Error: -d must be 'yes' or 'no'"
  usage
fi

echo "Creating project: $PROJECT_NAME"
gcloud projects create "$PROJECT_NAME"

if [[ "$DEFAULT_FLAG" == "yes" ]]; then
  echo "Setting project as default"
  gcloud config set project "$PROJECT_NAME"
else
  echo "Skipping default project switch"
fi

echo "Enabling required APIs"
gcloud services enable \
  compute.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  storage.googleapis.com

echo "Project setup complete."
