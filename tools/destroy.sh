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

# Delete orphaned Azure Container Registries
az acr list --query "[].name" -o tsv | while read -r acr; do
  az acr delete --name "$acr" --yes
done

# Delete orphaned Azure Storage Accounts
az storage account list --query "[].name" -o tsv | while read -r sa; do
  az storage account delete --name "$sa" --yes
done

# Delete orphaned Azure Key Vaults
az keyvault list --query "[].name" -o tsv | while read -r kv; do
  az keyvault delete --name "$kv"
done

# Delete orphaned AKS clusters
az aks list --query "[].{name:name, rg:resourceGroup}" -o tsv | while read -r name rg; do
  az aks delete --name "$name" --resource-group "$rg" --yes --no-wait
done

# Delete orphaned DNS zones
az network dns zone list --query "[].{name:name, rg:resourceGroup}" -o tsv | while read -r name rg; do
  az network dns zone delete --name "$name" --resource-group "$rg" --yes
done