output "lambda_function_names" {
  value = {
    for k, mod in module.r_lambda :
    k => mod.function_name
  }
}

output "lambda_arns" {
  value = {
    for k, mod in module.r_lambda :
    k => mod.lambda_arn
  }
}

output "python_lambda_function_name" {
  value = module.r_lambda["python_ai_lambda"].function_name
}

output "python_lambda_arn" {
  value = module.r_lambda["python_ai_lambda"].lambda_arn
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}
