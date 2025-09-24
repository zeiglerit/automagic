variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket containing Lambda zip"
  type        = string
}

variable "s3_key" {
  description = "S3 key for Lambda zip file"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
}

variable "handler" {
  description = "Lambda handler"
  type        = string
}

variable "aws_iam_role_arn" {
  description = "IAM role ARN for the Lambda function"
  type        = string
}
