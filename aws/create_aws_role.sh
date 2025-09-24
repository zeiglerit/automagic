#!/bin/bash

## usage: ./create_aws_role.sh --RoleName=TerraformExecutionRole

# Parse --RoleName argument
for arg in "$@"; do
  case $arg in
    --RoleName=*)
      ROLE_NAME="${arg#*=}"
      shift
      ;;
    *)
      echo "Usage: $0 --RoleName=YourRoleName"
      exit 1
      ;;
  esac
done

if [ -z "$ROLE_NAME" ]; then
  echo "Error: --RoleName argument is required"
  exit 1
fi

TRUST_POLICY_FILE="./trust-policy.json"

# Step 1: Create trust policy
cat > "$TRUST_POLICY_FILE" <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create the role
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document file://"$TRUST_POLICY_FILE"

#  Attach admin policy
aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"

#  Verify and output ARN
echo -e "\n✅ Role '$ROLE_NAME' created:"
aws iam get-role \
  --role-name "$ROLE_NAME" \
  --query "Role.Arn" \
  --output text
