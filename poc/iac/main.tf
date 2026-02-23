module "aws_foundation" {
  source     = "./aws/eks"
  aws_region = var.aws_region
}

module "azure_foundation" {
  source         = "./azure/aks"
  azure_region = var.azure_region
}

module "vpc" {
  source = "./modules/vpc"
}

module "network" {
  source = "./modules/network"
}
