resource "google_storage_bucket" "tf_state" {
  name          = "${var.project_id}-tfstate"
  location      = var.region
  force_destroy = false

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}
