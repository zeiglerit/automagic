provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "multilang-lambda"
      Environment = "dev"
      Owner       = "james"
      Terraform   = "true"
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_layer_version" "python_ai_deps" {
  layer_name          = "python-ai-deps"
  description         = "OpenAI, LangChain, NumPy, Matplotlib"
  compatible_runtimes = ["python3.11"]
  filename            = "${path.module}/../../python_layer/layer.zip"
}

resource "aws_lambda_function" "python_ai" {
  function_name = "python_ai_lambda"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  filename      = "${path.module}/../../python_lambda/handler.zip"
  source_code_hash = filebase64sha256("${path.module}/../../python_lambda/handler.zip")
  timeout       = 30
  memory_size   = 512

  layers = [aws_lambda_layer_version.python_ai_deps.arn]
}

resource "aws_lambda_function" "r_lambda" {
  function_name = "r_lambda_custom"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda.R"
  runtime       = "provided.al2"
  filename      = "${path.module}/../../r_lambda/r_lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../../r_lambda/r_lambda.zip")
  timeout       = 30
  memory_size   = 512
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name          = "lambda-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.lambda_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.python_ai.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "POST /invoke"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.lambda_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.python_ai.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*"
}

output "python_lambda_name" {
  value = aws_lambda_function.python_ai.function_name
}

output "r_lambda_name" {
  value = aws_lambda_function.r_lambda.function_name
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.lambda_api.api_endpoint
}
