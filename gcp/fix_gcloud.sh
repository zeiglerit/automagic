# ================================
# WSL-SAFE GCP BOOTSTRAP SCRIPT
# ================================

echo ">>> Removing Windows gcloud from PATH"
export PATH=$(echo $PATH | tr ':' '\n' | grep -v "Program Files" | paste -sd:)

echo ">>> Downloading Linux gcloud CLI"
curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-470.0.0-linux-x86_64.tar.gz

echo ">>> Extracting"
tar -xf google-cloud-cli-470.0.0-linux-x86_64.tar.gz

echo ">>> Installing Linux-native gcloud"
./google-cloud-sdk/install.sh --quiet

echo ">>> Updating PATH"
source ~/.bashrc 2>/dev/null || true
source ~/.zshrc 2>/dev/null || true

echo ">>> Fixing gcloud config permissions"
mkdir -p ~/.config/gcloud
chmod -R 700 ~/.config/gcloud

echo ">>> Installing beta components"
gcloud components install beta --quiet

echo ">>> Logging in (browserless)"
gcloud auth login --no-launch-browser

echo ">>> Setting up ADC (browserless)"
gcloud auth application-default login --no-launch-browser

echo ">>> Verifying ADC"
ls -l ~/.config/gcloud/application_default_credentials.json

echo ">>> Listing billing accounts"
gcloud billing accounts list

echo ">>> Bootstrap complete"
echo "Your WSL environment is now fully ready for Terraform + GCP."
