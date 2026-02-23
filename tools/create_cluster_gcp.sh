#!/bin/bash

# ================================
# CONFIGURE THESE VALUES
# ================================
PROJECT_ID="jfz-gke-lab2"
BILLING_ACCOUNT=$(gcloud beta billing accounts list --format="value(ACCOUNT_ID)" | head -n 1)
CLUSTER_NAME="gke-prod"
ZONE="us-central1-a"
MACHINE_TYPE="e2-medium"
NODE_COUNT=1
# ================================

echo "Checking if project '$PROJECT_ID' already exists..."

PROJECT_EXISTS=$(gcloud projects list --format="value(projectId)" | grep -w "$PROJECT_ID")

if [[ -z "$PROJECT_EXISTS" ]]; then
    echo "Project does NOT exist. Creating project: $PROJECT_ID"

    gcloud projects create $PROJECT_ID

    echo "Linking billing account..."
    gcloud beta billing projects link $PROJECT_ID \
      --billing-account=$BILLING_ACCOUNT

    echo "Enabling required APIs..."
    gcloud services enable container.googleapis.com --project $PROJECT_ID
    gcloud services enable compute.googleapis.com --project $PROJECT_ID
else
    echo "Project already exists. Skipping creation and billing link."
fi

echo "Setting active project..."
gcloud config set project $PROJECT_ID

echo "Creating GKE cluster (if not exists)..."

# Check if cluster exists
CLUSTER_EXISTS=$(gcloud container clusters list --zone $ZONE --format="value(name)" | grep -w "$CLUSTER_NAME")

if [[ -z "$CLUSTER_EXISTS" ]]; then
    echo "Cluster does NOT exist. Creating cluster: $CLUSTER_NAME"

    gcloud container clusters create $CLUSTER_NAME \
      --zone $ZONE \
      --machine-type $MACHINE_TYPE \
      --num-nodes $NODE_COUNT \
      --enable-ip-alias
else
    echo "Cluster already exists. Skipping creation."
fi

echo "Fetching kubeconfig..."
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE

echo "Done. Current kube contexts:"
kubectl config get-contexts
