module "iam_roles" {
  source               = "./modules/iam"
  lambda_trust_policy  = file("${path.module}/policies/lambda_trust.json")
  lambda_policy        = file("${path.module}/policies/lambda_policy.json")
}

module "lambda_functions" {
  source          = "./modules/lambda_functions"
  function_name   = var.function_name
  runtime         = var.runtime
  handler         = var.handler
  s3_bucket       = var.s3_bucket
  s3_key          = var.s3_key
  lambda_role_arn = module.iam_roles.lambda_exec_arn
}

module "sagemaker_model" {
  source         = "./modules/sagemaker_model"
  model_name     = "automagic-xgboost"
  execution_role = module.iam_roles.lambda_exec_arn
  image_uri = "683313688378.dkr.ecr.us-east-2.amazonaws.com/xgboost:1.5-1"
  s3_bucket      = var.s3_bucket
  s3_key         = var.s3_key
}

module "lambda_new_function" {
  source          = "./modules/lambda_functions"
  function_name   = "automagic-new-function"
  runtime         = "python3.9"
  handler         = "main.handler"
  s3_bucket       = var.s3_bucket
  s3_key          = "lambda/new-function.zip"
  lambda_role_arn = module.iam_roles.lambda_exec_arn
}

#resource "aws_iam_role" "lambda_exec" {
#  name               = "lambda_exec_role"
#  assume_role_policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Effect = "Allow"
#        Principal = {
#          Service = "lambda.amazonaws.com"
#        }
#        Action = "sts:AssumeRole"
#      }
#    ]
#  })
#}

