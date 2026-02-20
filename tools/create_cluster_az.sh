#!/bin/bash

# Variables
RESOURCE_GROUP="aks-rg"
CLUSTER_NAME="aks-prod"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create AKS cluster
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 2 \
  --node-vm-size standard_b2s \
  --generate-ssh-keys

# Get kubeconfig
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME

# Verify context
kubectl config get-contexts
