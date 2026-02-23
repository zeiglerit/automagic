variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Default region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Default zone for resources"
  type        = string
  default     = "us-central1-a"
}

variable "admin_ip" {
  type        = string
  description = "Your public IP for SSH access"
}
