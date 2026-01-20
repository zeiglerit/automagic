#!/usr/bin/env bash
set -euo pipefail

# OPA deploy script for Ubuntu
# - Installs latest OPA Linux AMD64 binary
# - Places it in /usr/local/bin
# - Verifies installation

OPA_BIN_NAME="opa"
OPA_INSTALL_PATH="/usr/local/bin/${OPA_BIN_NAME}"
OPA_DOWNLOAD_URL="https://openpolicyagent.org/downloads/latest/opa_linux_amd64"

echo "[INFO] Starting OPA installation..."

# Require root or sudo
if [[ "$EUID" -ne 0 ]]; then
    echo "[ERROR] This script must be run as root (use sudo)." >&2
    exit 1
fi

# Create a temp dir
TMP_DIR="$(mktemp -d)"
cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "[INFO] Downloading OPA from: ${OPA_DOWNLOAD_URL}"
curl -L -o "${TMP_DIR}/${OPA_BIN_NAME}" "${OPA_DOWNLOAD_URL}"

echo "[INFO] Making OPA binary executable..."
chmod +x "${TMP_DIR}/${OPA_BIN_NAME}"

echo "[INFO] Moving OPA to ${OPA_INSTALL_PATH}..."
mv "${TMP_DIR}/${OPA_BIN_NAME}" "${OPA_INSTALL_PATH}"

echo "[INFO] Verifying OPA installation..."
if ! command -v "${OPA_BIN_NAME}" >/dev/null 2>&1; then
    echo "[ERROR] OPA is not in PATH after installation." >&2
    exit 1
fi

"${OPA_BIN_NAME}" version || {
    echo "[ERROR] OPA binary exists but failed to run." >&2
    exit 1
}

echo "[SUCCESS] OPA installed successfully at ${OPA_INSTALL_PATH}"
echo "[INFO] Try: opa run --server"
