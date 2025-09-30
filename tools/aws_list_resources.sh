#!/bin/bash

# Usage: ./list_aws_resources.sh --tag Project=multilang-lambda

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --tag)
      TAG_PAIR="$2"
      shift
      ;;
    *)
      echo "Unknown parameter passed: $1"
      exit 1
      ;;
  esac
  shift
done

# Split TAG_PAIR into key and value
TAG_KEY="${TAG_PAIR%%=*}"
TAG_VALUE="${TAG_PAIR#*=}"
REGION="us-east-1"

echo "Listing AWS resources tagged with $TAG_KEY=$TAG_VALUE in $REGION..."

aws resourcegroupstaggingapi get-resources \
  --tag-filters Key="$TAG_KEY",Values="$TAG_VALUE" \
  --region "$REGION" \
  --query 'ResourceTagMappingList[].ResourceARN' \
  --output table
