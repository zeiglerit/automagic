#!/usr/bin/env bash

set -euo pipefail

MODE=""
AWS_RESULT=""
AZURE_RESULT=""
GCP_RESULT=""

usage() {
  echo "Usage: $0 --mode [c|d]"
  echo "  c = check cluster status"
  echo "  d = destroy clusters"
  exit 1
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode|-m)
      MODE="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

[[ -z "$MODE" ]] && usage

echo "===================================================="
echo " Multi‑Cloud Cluster Manager"
echo " Mode: $MODE"
echo "===================================================="

##############################################
# AWS
##############################################
echo ""
echo ">>> AWS"
if ! command -v aws >/dev/null 2>&1; then
  AWS_RESULT="AWS CLI not installed"
  echo "AWS: CLI missing, skipping"
else
  if [[ "$MODE" == "c" ]]; then
    if aws eks list-clusters --output text >/dev/null 2>&1; then
      CLUSTERS=$(aws eks list-clusters --output text)
      if [[ -z "$CLUSTERS" ]]; then
        AWS_RESULT="No clusters found"
        echo "AWS: No clusters found"
      else
        AWS_RESULT="Clusters found: $CLUSTERS"
        echo "AWS clusters:"
        echo "$CLUSTERS"
      fi
    else
      AWS_RESULT="Error checking clusters"
      echo "AWS: Error checking clusters"
    fi
  elif [[ "$MODE" == "d" ]]; then
    CLUSTERS=$(aws eks list-clusters --output text 2>/dev/null || true)
    if [[ -z "$CLUSTERS" ]]; then
      AWS_RESULT="No clusters to delete"
      echo "AWS: No clusters to delete"
    else
      for C in $CLUSTERS; do
        echo "Deleting AWS cluster: $C"
        if aws eks delete-cluster --name "$C" >/dev/null 2>&1; then
          echo "Deleted: $C"
        else
          echo "Failed to delete: $C"
        fi
      done
      AWS_RESULT="Delete attempted for: $CLUSTERS"
    fi
  fi
fi

##############################################
# AZURE
##############################################
echo ""
echo ">>> Azure"
if ! command -v az >/dev/null 2>&1; then
  AZURE_RESULT="Azure CLI not installed"
  echo "Azure: CLI missing, skipping"
else
  if [[ "$MODE" == "c" ]]; then
    if az aks list >/dev/null 2>&1; then
      CLUSTERS=$(az aks list --query "[].name" -o tsv)
      if [[ -z "$CLUSTERS" ]]; then
        AZURE_RESULT="No clusters found"
        echo "Azure: No clusters found"
      else
        AZURE_RESULT="Clusters found: $CLUSTERS"
        echo "Azure clusters:"
        echo "$CLUSTERS"
      fi
    else
      AZURE_RESULT="Error checking clusters"
      echo "Azure: Error checking clusters"
    fi
  elif [[ "$MODE" == "d" ]]; then
    CLUSTERS=$(az aks list --query "[].{name:name,rg:resourceGroup}" -o tsv 2>/dev/null || true)
    if [[ -z "$CLUSTERS" ]]; then
      AZURE_RESULT="No clusters to delete"
      echo "Azure: No clusters to delete"
    else
      while read -r NAME RG; do
        echo "Deleting Azure cluster: $NAME (RG: $RG)"
        if az aks delete --name "$NAME" --resource-group "$RG" --yes --no-wait >/dev/null 2>&1; then
          echo "Delete started: $NAME"
        else
          echo "Failed to delete: $NAME"
        fi
      done <<< "$CLUSTERS"
      AZURE_RESULT="Delete attempted for Azure clusters"
    fi
  fi
fi

##############################################
# GCP
##############################################
echo ""
echo ">>> GCP"
if ! command -v gcloud >/dev/null 2>&1; then
  GCP_RESULT="GCloud CLI not installed"
  echo "GCP: CLI missing, skipping"
else
  if [[ "$MODE" == "c" ]]; then
    if gcloud container clusters list >/dev/null 2>&1; then
      CLUSTERS=$(gcloud container clusters list --format="value(name)")
      if [[ -z "$CLUSTERS" ]]; then
        GCP_RESULT="No clusters found"
        echo "GCP: No clusters found"
      else
        GCP_RESULT="Clusters found: $CLUSTERS"
        echo "GCP clusters:"
        echo "$CLUSTERS"
      fi
    else
      GCP_RESULT="Error checking clusters"
      echo "GCP: Error checking clusters"
    fi
  elif [[ "$MODE" == "d" ]]; then
    CLUSTERS=$(gcloud container clusters list --format="value(name,location)" 2>/dev/null || true)
    if [[ -z "$CLUSTERS" ]]; then
      GCP_RESULT="No clusters to delete"
      echo "GCP: No clusters to delete"
    else
      while read -r NAME LOC; do
        echo "Deleting GCP cluster: $NAME (location: $LOC)"
        if gcloud container clusters delete "$NAME" --zone "$LOC" --quiet >/dev/null 2>&1; then
          echo "Deleted: $NAME"
        else
          echo "Failed to delete: $NAME"
        fi
      done <<< "$CLUSTERS"
      GCP_RESULT="Delete attempted for GCP clusters"
    fi
  fi
fi

##############################################
# SUMMARY
##############################################
echo ""
echo "===================================================="
echo " Summary"
echo "===================================================="
echo "AWS:   $AWS_RESULT"
echo "Azure: $AZURE_RESULT"
echo "GCP:   $GCP_RESULT"
echo "===================================================="
