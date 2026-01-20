#resource "google_storage_bucket" "tf_state" {
#  name          = "${var.project_id}-tfstate"
#  location      = "US"
#  force_destroy = false
#  versioning { enabled = true }
#}
