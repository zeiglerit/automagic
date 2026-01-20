#!/usr/bin/env bash
#
# Generate a nested directory + file structure based on data/files.txt.
# Usage:
#   ./dirs_files_nested.sh --name myapp
#
# This will create:
#   app/myapp/<all paths from files.txt>

set -euo pipefail

###############################################
# ARGUMENT PARSING
###############################################

APP_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      APP_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$APP_NAME" ]]; then
  echo "Error: --name <appname> is required"
  exit 1
fi

###############################################
# INPUT + OUTPUT PATHS
###############################################

FILES_LIST="data/files.txt"
OUTPUT_ROOT="app/$APP_NAME"

if [[ ! -f "$FILES_LIST" ]]; then
  echo "Error: $FILES_LIST not found"
  exit 1
fi

echo "Generating scaffold for app: $APP_NAME"
echo "Using file list: $FILES_LIST"
echo "Output root: $OUTPUT_ROOT"
echo

###############################################
# EXECUTION
###############################################

while IFS= read -r path; do
  # Skip empty lines
  [[ -z "$path" ]] && continue

  # Build full output path
  full_path="$OUTPUT_ROOT/$path"

  # Create directory and file
  mkdir -p "$(dirname "$full_path")"
  touch "$full_path"

  echo "Created: $full_path"
done < "$FILES_LIST"

echo
echo "Done. Structure created under: $OUTPUT_ROOT/"
