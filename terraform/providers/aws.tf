provider "aws" {
  region = "us-west-2" # ← match your S3 bucket region
}
output "lambda_function_name" {
  value = module.r_lambda.function_name
}

output "lambda_arn" {
  value = module.r_lambda.lambda_arn
}
