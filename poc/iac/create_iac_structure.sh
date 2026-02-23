#!/usr/bin/env bash

set -e

echo "Rebuilding IaC directory structure..."

# Clean slate
rm -rf aws azure global modules
mkdir -p aws/eks
mkdir -p azure/aks
mkdir -p global
mkdir -p modules/vpc
mkdir -p modules/network
mkdir -p modules/eks
mkdir -p modules/aks

############################################
# ROOT MODULE
############################################

cat > versions.tf << 'EOF'
terraform {
  required_version = ">= 1.6.0"

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
EOF

cat > providers.tf << 'EOF'
provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}
EOF

cat > variables.tf << 'EOF'
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "azure_location" {
  type    = string
  default = "eastus"
}
EOF

cat > main.tf << 'EOF'
module "aws_foundation" {
  source     = "./aws/eks"
  aws_region = var.aws_region
}

module "azure_foundation" {
  source         = "./azure/aks"
  azure_location = var.azure_location
}

module "vpc" {
  source = "./modules/vpc"
}

module "network" {
  source = "./modules/network"
}
EOF

############################################
# AWS EKS MODULE
############################################

cat > aws/eks/main.tf << 'EOF'
module "vpc" {
  source = "../../modules/vpc"
}

output "eks_ready" {
  value = true
}
EOF

############################################
# AZURE AKS MODULE
############################################

cat > azure/aks/main.tf << 'EOF'
resource "azurerm_resource_group" "rg" {
  name     = "lab-rg"
  location = var.azure_location
}

output "aks_ready" {
  value = true
}
EOF

############################################
# MODULES: VPC
############################################

cat > modules/vpc/main.tf << 'EOF'
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "lab-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
EOF

############################################
# MODULES: NETWORK (placeholder)
############################################

cat > modules/network/main.tf << 'EOF'
output "network_ready" {
  value = true
}
EOF

############################################
# MODULES: EKS (placeholder)
############################################

cat > modules/eks/main.tf << 'EOF'
output "eks_module_ready" {
  value = true
}
EOF

############################################
# MODULES: AKS (placeholder)
############################################

cat > modules/aks/main.tf << 'EOF'
output "aks_module_ready" {
  value = true
}
EOF

echo "IaC structure created successfully."
echo "Next steps:"
echo "  terraform init"
echo "  terraform validate"
echo "  terraform plan"
