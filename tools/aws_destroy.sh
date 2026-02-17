#!/bin/bash

set -euo pipefail

regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

echo "Regions detected:"
echo "$regions"
echo

for region in $regions; do
  echo "=============================="
  echo "Destroying resources in region: $region"
  echo "=============================="

  # -----------------------------
  # EC2 Instances
  # -----------------------------
  echo "Terminating EC2 instances..."
  instances=$(aws ec2 describe-instances --region $region --query "Reservations[].Instances[].InstanceId" --output text)
  if [[ -n "$instances" ]]; then
    aws ec2 terminate-instances --region $region --instance-ids $instances
  fi

  # -----------------------------
  # NAT Gateways
  # -----------------------------
  echo "Deleting NAT Gateways..."
  natgws=$(aws ec2 describe-nat-gateways --region $region --query "NatGateways[].NatGatewayId" --output text)
  for nat in $natgws; do
    aws ec2 delete-nat-gateway --region $region --nat-gateway-id $nat
  done

  # -----------------------------
  # Load Balancers
  # -----------------------------
  echo "Deleting ALBs/NLBs..."
  lbs=$(aws elbv2 describe-load-balancers --region $region --query "LoadBalancers[].LoadBalancerArn" --output text)
  for lb in $lbs; do
    aws elbv2 delete-load-balancer --region $region --load-balancer-arn $lb
  done

  echo "Deleting Classic ELBs..."
  clbs=$(aws elb describe-load-balancers --region $region --query "LoadBalancerDescriptions[].LoadBalancerName" --output text)
  for clb in $clbs; do
    aws elb delete-load-balancer --region $region --load-balancer-name $clb
  done

  # -----------------------------
  # EKS Clusters
  # -----------------------------
  echo "Deleting EKS clusters..."
  eks_clusters=$(aws eks list-clusters --region $region --query "clusters[]" --output text)
  for c in $eks_clusters; do
    aws eks delete-cluster --region $region --name "$c"
  done

  # -----------------------------
  # RDS
  # -----------------------------
  echo "Deleting RDS instances..."
  rds=$(aws rds describe-db-instances --region $region --query "DBInstances[].DBInstanceIdentifier" --output text)
  for db in $rds; do
    aws rds delete-db-instance --region $region --db-instance-identifier $db --skip-final-snapshot
  done

  # -----------------------------
  # DynamoDB
  # -----------------------------
  echo "Deleting DynamoDB tables..."
  tables=$(aws dynamodb list-tables --region $region --query "TableNames[]" --output text)
  for t in $tables; do
    aws dynamodb delete-table --region $region --table-name $t
  done

  # -----------------------------
  # Lambda
  # -----------------------------
  echo "Deleting Lambda functions..."
  lambdas=$(aws lambda list-functions --region $region --query "Functions[].FunctionName" --output text)
  for fn in $lambdas; do
    aws lambda delete-function --region $region --function-name $fn
  done

  # -----------------------------
  # VPC Cleanup
  # -----------------------------
  echo "Deleting VPCs..."
  vpcs=$(aws ec2 describe-vpcs --region $region --query "Vpcs[].VpcId" --output text)

  for vpc in $vpcs; do
    echo "Cleaning VPC: $vpc"

    # Endpoints
    eps=$(aws ec2 describe-vpc-endpoints --region $region --filters Name=vpc-id,Values=$vpc --query "VpcEndpoints[].VpcEndpointId" --output text)
    for ep in $eps; do
      aws ec2 delete-vpc-endpoints --region $region --vpc-endpoint-ids $ep
    done

    # Detach & delete IGWs
    igws=$(aws ec2 describe-internet-gateways --region $region --filters Name=attachment.vpc-id,Values=$vpc --query "InternetGateways[].InternetGatewayId" --output text)
    for igw in $igws; do
      aws ec2 detach-internet-gateway --region $region --internet-gateway-id $igw --vpc-id $vpc
      aws ec2 delete-internet-gateway --region $region --internet-gateway-id $igw
    done

    # Delete subnets
    subnets=$(aws ec2 describe-subnets --region $region --filters Name=vpc-id,Values=$vpc --query "Subnets[].SubnetId" --output text)
    for sn in $subnets; do
      aws ec2 delete-subnet --region $region --subnet-id $sn
    done

    # Delete route tables
    rts=$(aws ec2 describe-route-tables --region $region --filters Name=vpc-id,Values=$vpc --query "RouteTables[].RouteTableId" --output text)
    for rt in $rts; do
      aws ec2 delete-route-table --region $region --route-table-id $rt 2>/dev/null
    done

    # Delete NACLs
    nacls=$(aws ec2 describe-network-acls --region $region --filters Name=vpc-id,Values=$vpc --query "NetworkAcls[?IsDefault==\`false\`].NetworkAclId" --output text)
    for nacl in $nacls; do
      aws ec2 delete-network-acl --region $region --network-acl-id $nacl
    done

    # Delete security groups (except default)
    sgs=$(aws ec2 describe-security-groups --region $region --filters Name=vpc-id,Values=$vpc --query "SecurityGroups[?GroupName!='default'].GroupId" --output text)
    for sg in $sgs; do
      aws ec2 delete-security-group --region $region --group-id $sg 2>/dev/null
    done

    # Finally delete VPC
    aws ec2 delete-vpc --region $region --vpc-id $vpc || echo "VPC still has dependencies"
  done

done

echo "=============================="
echo "Deleting global S3 buckets..."
echo "=============================="

buckets=$(aws s3api list-buckets --query "Buckets[].Name" --output text)
for b in $buckets; do
  aws s3 rb "s3://$b" --force || true
done

echo "=============================="
echo "Deleting IAM roles..."
echo "=============================="

roles=$(aws iam list-roles --query "Roles[].RoleName" --output text)
for r in $roles; do
  if [[ "$r" != AWSServiceRoleFor* ]]; then
    aws iam delete-role --role-name "$r" 2>/dev/null || true
  fi
done

echo "AWS destroy complete."
