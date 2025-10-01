#!/bin/bash

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
PATTERNS=(
  "password\s*=\s*['\"]?.+['\"]?"
  "passwd\s*=\s*['\"]?.+['\"]?"
  "secret\s*=\s*['\"]?.+['\"]?"
  "token\s*=\s*['\"]?.+['\"]?"
  "api[_-]?key\s*=\s*['\"]?.+['\"]?"
  "access[_-]?key\s*=\s*['\"]?.+['\"]?"
  "username\s*=\s*['\"]?.+['\"]?"
  "login\s*=\s*['\"]?.+['\"]?"
  "auth\s*=\s*['\"]?.+['\"]?"
)

echo "🔍 Scanning repo for insecure strings..."
cd "$REPO_ROOT" || exit 1

for pattern in "${PATTERNS[@]}"; do
  echo "Searching for: $pattern"
  grep -rIn --exclude-dir={.git,__pycache__,node_modules,venv} --color=always "$pattern" . || true
done

echo "✅ Scan complete."
