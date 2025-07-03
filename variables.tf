variable "project_id" {
  description = "The GCP project ID"
  type        = string
  default     = "my-terraform-456814"  # Change this to your actual project ID
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}
