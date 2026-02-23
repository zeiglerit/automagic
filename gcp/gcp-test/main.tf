terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project     = "jfz-test-infra"
  region      = "us-central1"
  credentials = file("~/terraform-key.json")
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "demo" {
  name     = "jfz-demo-bucket-${random_id.suffix.hex}"
  location = "US"
}
