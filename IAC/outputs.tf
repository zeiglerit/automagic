output "lambda_function_name" {
  value = module.lambda_functions.function_name
}

output "lambda_exec_arn" {
  value = module.iam_roles.lambda_exec_arn
}

output "lambda_function_arn" {
  value = module.lambda_functions.arn
}
