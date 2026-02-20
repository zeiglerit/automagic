#!/bin/bash

# ================================
# CONFIGURE THESE VALUES
# ================================
PROJECT_NAME="jfz-gke-lab"
BILLING_ACCOUNT=$(gcloud beta billing accounts list | head -n 2 | awk '{print $1}' | grep -v ACC)
ORG_ID=""   # optional, leave empty if not using orgs
FOLDER_ID="" # optional
CLUSTER_NAME="gke-prod"
ZONE="us-central1-a"
MACHINE_TYPE="e2-medium"
NODE_COUNT=1
# ================================

echo "Creating GCP project..."

if [[ -n "$ORG_ID" ]]; then
  gcloud projects create $PROJECT_NAME --organization=$ORG_ID
elif [[ -n "$FOLDER_ID" ]]; then
  gcloud projects create $PROJECT_NAME --folder=$FOLDER_ID
else
  gcloud projects create $PROJECT_NAME
fi

echo "Linking billing account..."
gcloud beta billing projects link $PROJECT_NAME \
  --billing-account=$BILLING_ACCOUNT

echo "Setting project..."
gcloud config set project $PROJECT_NAME

echo "Enabling required APIs..."
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com

echo "Creating GKE cluster..."
gcloud container clusters create $CLUSTER_NAME \
  --zone $ZONE \
  --machine-type $MACHINE_TYPE \
  --num-nodes $NODE_COUNT \
  --enable-ip-alias

echo "Fetching kubeconfig..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

echo "Done. Current kube contexts:"
kubectl config get-contexts
