resource "aws_sfn_state_machine" "workflow" {
  name     = "dev-workflow"
  role_arn = aws_iam_role.lambda_role.arn

  definition = jsonencode({
    StartAt = "Process"
    States = {
      Process = {
        Type = "Task"
        Resource = var.lambda_arn
        End = true
      }
    }
  })
}
