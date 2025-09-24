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
  image_uri      = "811284229777.dkr.ecr.us-east-2.amazonaws.com/xgboost:latest"
}
