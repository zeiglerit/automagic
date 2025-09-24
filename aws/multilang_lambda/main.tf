resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.aws_iam_role_arn
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key
  runtime       = var.runtime
  handler       = var.handler
}
