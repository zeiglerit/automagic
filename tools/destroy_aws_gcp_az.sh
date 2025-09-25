#!/bin/bash
set -euo pipefail

# Destroy Terraform-managed resources
cd "$(dirname "$0")/../terraform"
terraform destroy -auto-approve

# GCP teardown
GCP_PROJECT="your-gcp-project-id"

# Delete all AI Platform models
gcloud ai models list --project="$GCP_PROJECT" --format="value(name)" | while read -r model; do
  gcloud ai models delete "$model" --project="$GCP_PROJECT" --quiet
done

# Delete all GCP buckets
gcloud storage buckets list --project="$GCP_PROJECT" --format="value(name)" | while read -r bucket; do
  gcloud storage buckets delete "$bucket" --project="$GCP_PROJECT" --quiet
done

# Azure teardown
AZURE_RG="your-azure-resource-group"

# Delete Azure resource group
az group delete --name "$AZURE_RG" --yes --no-wait
