module "eks" {
    source          = "terraform-aws-modules/eks/aws"
    cluster_name    = "fintech-eks"
    cluster_version = "1.29"

    vpc_id      = var.vpc_id
    subnet_ids  = var.subnet_ids

    manage_aws_auth = true
}