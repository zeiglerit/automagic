aws_iam_role_arn = "arn:aws:iam::123456789012:role/your-role-name"
s3_bucket        = "your-s3-bucket-name"

lambda_functions = {
  r_lambda_custom    = "lambda-packages/r_lambda_custom.zip"
  python_ai_lambda   = "lambda-packages/python_ai_lambda.zip"
}
