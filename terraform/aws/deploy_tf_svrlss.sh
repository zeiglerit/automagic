#!/usr/bin/env bash

echo "Creating full Terraform AWS project with file contents..."

############################################
# ROOT FILES
############################################

cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}

module "lambda" {
  source = "./modules/lambda"
}

module "stepfunctions" {
  source = "./modules/stepfunctions"
}
EOF

cat > variables.tf <<'EOF'
variable "region" {
  type    = string
  default = "us-east-1"
}
EOF

cat > outputs.tf <<'EOF'
output "vpc_id" {
  value = module.vpc.vpc_id
}
EOF

cat > providers.tf <<'EOF'
provider "aws" {
  region = var.region
}
EOF


############################################
# ENVIRONMENT FILES
############################################

mkdir -p env/dev

cat > env/dev/backend.tf <<'EOF'
terraform {
  backend "s3" {
    bucket = "my-terraform-state-dev"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
EOF

cat > env/dev/terraform.tfvars <<'EOF'
region = "us-east-1"
EOF


############################################
# MODULE: VPC
############################################

mkdir -p modules/vpc

cat > modules/vpc/main.tf <<'EOF'
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

output "vpc_id" {
  value = aws_vpc.main.id
}
EOF

cat > modules/vpc/variables.tf <<'EOF'
# No variables yet
EOF

cat > modules/vpc/outputs.tf <<'EOF'
output "vpc_id" {
  value = aws_vpc.main.id
}
EOF


############################################
# MODULE: LAMBDA
############################################

mkdir -p modules/lambda

cat > modules/lambda/main.tf <<'EOF'
resource "aws_iam_role" "lambda_role" {
  name = "lambda-basic-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_lambda_function" "processor" {
  function_name = "processor-dev"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = "lambda.zip"
  role          = aws_iam_role.lambda_role.arn
}
EOF

cat > modules/lambda/variables.tf <<'EOF'
# No variables yet
EOF

cat > modules/lambda/outputs.tf <<'EOF'
output "lambda_arn" {
  value = aws_lambda_function.processor.arn
}
EOF


############################################
# MODULE: STEP FUNCTIONS
############################################

mkdir -p modules/stepfunctions

cat > modules/stepfunctions/main.tf <<'EOF'
resource "aws_sfn_state_machine" "workflow" {
  name     = "dev-workflow"
  role_arn = aws_iam_role.lambda_role.arn

  definition = jsonencode({
    StartAt = "Process"
    States = {
      Process = {
        Type = "Task"
        Resource = var.lambda_arn
        End = true
      }
    }
  })
}
EOF

cat > modules/stepfunctions/variables.tf <<'EOF'
variable "lambda_arn" {
  type = string
}
EOF

cat > modules/stepfunctions/outputs.tf <<'EOF'
output "workflow_arn" {
  value = aws_sfn_state_machine.workflow.arn
}
EOF


############################################
# SERVICE FOLDERS (OPTIONAL)
############################################

mkdir -p vpc lambda stepfunctions api

touch vpc/vpc.tf
touch lambda/lambda.tf
touch stepfunctions/workflow.tf
touch api/api.tf

echo "Project created successfully."
