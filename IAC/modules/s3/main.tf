resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  versioning {
    enabled = var.versioning
  }
}
