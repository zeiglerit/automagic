module "vpc" {
  source = "../../modules/vpc"
}

output "eks_ready" {
  value = true
}
