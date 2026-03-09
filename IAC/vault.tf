provider "vault" {
  address = "http://127.0.0.1:8200"
}

data "vault_aws_access_credentials" "terraform" {
  backend = "aws"
  role    = "terraform-role"
}

provider "aws" {
  access_key = data.vault_aws_access_credentials.terraform.access_key
  secret_key = data.vault_aws_access_credentials.terraform.secret_key
  region     = "us-east-1"
}
