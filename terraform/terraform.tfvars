aws_region = "us-east-2"

aws_iam_role_arn = "arn:aws:iam::558162184322:role/lambda_exec_role_east2"
#aws_iam_role_arn = "arn:aws:iam::558162184322:role/TerraformExecutionRole"
s3_bucket        = "automagic-lambda-packages"

lambda_functions = {
  r_lambda_custom    = "r_lambda.zip"
  python_ai_lambda   = "python_ai_lambda.zip"
}
