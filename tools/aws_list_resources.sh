#!/bin/bash

REGION="us-east-2"
echo "Listing AWS resources in region: $REGION"

# Tagged Resources
echo -e "\nTagged Resources:"
tagged=$(aws resourcegroupstaggingapi get-resources \
  --region "$REGION" \
  --query 'ResourceTagMappingList' \
  --output table)
if [[ -z "$tagged" || "$tagged" == "None" ]]; then
  echo "  ..NADA"
else
  echo "$tagged"
fi

# EC2 Instances
echo -e "\nEC2 Instances:"
ec2=$(aws ec2 describe-instances \
  --region "$REGION" \
  --query 'Reservations[].Instances[].InstanceId' \
  --output table)
if [[ -z "$ec2" || "$ec2" == "None" ]]; then
  echo "  ..NADA"
else
  echo "$ec2"
fi

# S3 Buckets (Global Scope)
echo -e "\nS3 Buckets:"
s3=$(aws s3api list-buckets \
  --query 'Buckets[].Name' \
  --output table)
if [[ -z "$s3" || "$s3" == "None" ]]; then
  echo "  ..NADA"
else
  echo "$s3"
fi
