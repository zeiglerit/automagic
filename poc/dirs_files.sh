#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="iac"

echo "📁 Creating Terraform project structure..."

# Base directories
mkdir -p $ROOT_DIR/global/backend

# AWS directories
mkdir -p $ROOT_DIR/aws/eks

# Azure directories
mkdir -p $ROOT_DIR/azure/aks

# Modules
mkdir -p $ROOT_DIR/modules/vpc
mkdir -p $ROOT_DIR/modules/network
mkdir -p $ROOT_DIR/modules/eks
mkdir -p $ROOT_DIR/modules/aks

###############################################
# Create placeholder Terraform files
###############################################

create_tf_files() {
  local dir=$1
  echo "📝 Creating Terraform files in $dir"

  cat > "$dir/main.tf" <<EOF
# main.tf
# Terraform configuration for $(basename $dir)
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}
EOF

  cat > "$dir/variables.tf" <<EOF
# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "azure_location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}
EOF

  cat > "$dir/outputs.tf" <<EOF
# outputs.tf
# Add outputs here
EOF
}

# Create TF files for AWS and Azure
create_tf_files "$ROOT_DIR/aws/eks"
create_tf_files "$ROOT_DIR/azure/aks"

###############################################
# Create module placeholders
###############################################

create_module_files() {
  local dir=$1
  echo "📦 Creating module in $dir"

  cat > "$dir/main.tf" <<EOF
# Module: $(basename $dir)
# Add module resources here
EOF

  touch "$dir/variables.tf"
  touch "$dir/outputs.tf"
}

create_module_files "$ROOT_DIR/modules/vpc"
create_module_files "$ROOT_DIR/modules/network"
create_module_files "$ROOT_DIR/modules/eks"
create_module_files "$ROOT_DIR/modules/aks"

###############################################
# Backend placeholders
###############################################

cat > "$ROOT_DIR/global/backend/backend.tf" <<EOF
# Remote backend configuration placeholder
# Fill in S3 or AzureRM backend details here
EOF

echo "🎉 Terraform directory structure created successfully!"
