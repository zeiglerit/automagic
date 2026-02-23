resource "aws_iam_role" "lambda_role" {
  name = "lambda-basic-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_lambda_function" "processor" {
  function_name = "processor-dev"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename      = "lambda.zip"
  role          = aws_iam_role.lambda_role.arn
}
