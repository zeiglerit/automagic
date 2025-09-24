resource "aws_sagemaker_model" "this" {
  name               = var.model_name
  execution_role_arn = var.execution_role
  primary_container {
    image = var.image_uri
  }
}
