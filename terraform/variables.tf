variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "function_name" {}
variable "s3_key" {}
variable "handler" {}
variable "runtime" {}
variable "lambda_role_arn" {}

variable "aws_iam_role_arn" {
  description = "IAM role ARN for Terraform to assume"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket containing Lambda zip"
  type        = string
}

variable "lambda_functions" {
  description = "Map of Lambda function names to their S3 zip paths"
  type        = map(string)
}
