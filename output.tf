# Outputs
output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "vpc_network_self_link" {
  description = "Self-link of the VPC network"
  value       = google_compute_network.vpc_network.self_link
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_cidr" {
  description = "CIDR block of the subnet"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "subnet_gateway" {
  description = "Gateway IP of the subnet"
  value       = google_compute_subnetwork.subnet.gateway_address
}

output "firewall_rules" {
  description = "List of firewall rules created"
  value = {
    internal     = google_compute_firewall.allow_internal.name
    ssh          = google_compute_firewall.allow_ssh.name
    http_https   = google_compute_firewall.allow_http_https.name
    rdp          = google_compute_firewall.allow_rdp.name
    health_check = google_compute_firewall.allow_health_checks.name
  }
}