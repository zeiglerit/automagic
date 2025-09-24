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
  source         = "../aws/multilang_lambda"
  function_name  = var.function_name
  s3_bucket      = var.s3_bucket
  s3_key         = var.s3_key
  runtime        = "provided.al2"
  handler        = "bootstrap"
}
module "lambda_deploy" {
  source                = "../modules/lambda"
  lambda_function_names = var.lambda_function_names
}
