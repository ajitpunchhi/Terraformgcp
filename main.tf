# Create VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
  description             = "Simple VPC network for ${var.environment} environment"
  
  depends_on = [
    google_project_service.compute_api
  ]
}

# Enable Compute Engine API
resource "google_project_service" "compute_api" {
  project = var.project_id
  service = "compute.googleapis.com"
  
  disable_on_destroy = false
}

# Create Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
  description   = "Subnet for ${var.environment} environment"
  
  # Enable private Google access
  private_ip_google_access = true
  
  # Secondary IP ranges for pods and services (useful for GKE)
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "10.1.0.0/16"
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.2.0.0/16"
  }
}

# Create Firewall Rule - Allow Internal Communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc_network.name
  
  description = "Allow internal communication between instances"
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.subnet_cidr]
  
  target_tags = ["internal"]
}

# Create Firewall Rule - Allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.vpc_network.name
  
  description = "Allow SSH access from anywhere"
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# Create Firewall Rule - Allow HTTP/HTTPS
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.network_name}-allow-http-https"
  network = google_compute_network.vpc_network.name
  
  description = "Allow HTTP and HTTPS traffic"
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

# Create Firewall Rule - Allow RDP (for Windows instances)
resource "google_compute_firewall" "allow_rdp" {
  name    = "${var.network_name}-allow-rdp"
  network = google_compute_network.vpc_network.name
  
  description = "Allow RDP access for Windows instances"
  
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["rdp"]
}

# Create Firewall Rule - Allow Health Checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.network_name}-allow-health-checks"
  network = google_compute_network.vpc_network.name
  
  description = "Allow health checks from Google Cloud Load Balancers"
  
  allow {
    protocol = "tcp"
  }
  
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
  
  target_tags = ["health-check"]
}