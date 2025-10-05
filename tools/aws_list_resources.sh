#!/bin/bash

REGION="us-east-2"
echo "🔍 Listing AWS resources in region: $REGION"

echo -e "\n📌 Tagged Resources:"
aws resourcegroupstaggingapi get-resources \
  --region "$REGION" \
  --output table

echo -e "\n📌 EC2 Instances:"
aws ec2 describe-instances \
  --region "$REGION" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output table

echo -e "\n📌 S3 Buckets (Global Scope):"
aws s3api list-buckets \
  --query 'Buckets[].Name' \
  --output table
