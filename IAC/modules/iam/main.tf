resource "aws_iam_role" "lambda_exec" {
  name               = "lambda_exec_role"
  assume_role_policy = var.lambda_trust_policy
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_exec_policy"
  role   = aws_iam_role.lambda_exec.id
  policy = var.lambda_policy
}
