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

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "my-vpc-network"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "my-subnet"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Create VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  description             = "Simple VPC network for ${var.environment} environment"
  
  depends_on = [
    google_project_service.compute_api
  ]
}