resource "google_vertex_ai_notebook_instance" "lab" {
  name   = "jfz-vertex-lab"
  region = "us-central1"

  machine_type = "n1-standard-4"

  vm_image {
    project = "deeplearning-platform-release"
    image_family = "common-cpu"
  }

  install_gpu_driver = false
}
