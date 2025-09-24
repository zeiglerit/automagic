aws_region = "us-east-1"

aws_iam_role_arn = "arn:aws:iam::558162184322:role/TerraformExecutionRole"
s3_bucket        = "automagic-lambda-packages2"

lambda_functions = {
  r_lambda_custom    = "lambda-packages/r_lambda_custom.zip"
  python_ai_lambda   = "lambda-packages/python_ai_lambda.zip"
}
