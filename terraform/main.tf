terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = var.aws_iam_role_arn
  }
}

module "r_lambda" {
  source    = "../aws/multilang_lambda"
  for_each  = var.lambda_functions

  function_name = each.key
  s3_bucket     = var.s3_bucket
  s3_key        = each.value
  runtime       = "provided.al2"
  handler       = "bootstrap"
  aws_iam_role_arn  = var.aws_iam_role_arn
}
