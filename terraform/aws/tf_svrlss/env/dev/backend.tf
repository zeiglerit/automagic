terraform {
  backend "s3" {
    bucket = "my-terraform-state-dev"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
