provider "aws" {
  region = "us-west-2" # ← match your S3 bucket region
}
output "lambda_function_name" {
  value = module.lambda_functions.function_name
}

output "lambda_arn" {
  value = module.lambda_functions.lambda_arn
}
