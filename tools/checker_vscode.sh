# Check VS Code server logs
cat ~/.vscode-server/.<version>/logs/* | grep -i error

# Check Azure CLI login status
az account show

# Check Docker socket access
ls -l /var/run/docker.sock

# Check Git permissions
git config --list --show-origin
