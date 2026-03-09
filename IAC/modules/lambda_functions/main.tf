resource "aws_lambda_function" "this" {
  function_name     = var.function_name
  runtime           = var.runtime
  handler           = var.handler
  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  role              = var.lambda_role_arn
  memory_size       = 128
  timeout           = 10
  publish           = true
}
