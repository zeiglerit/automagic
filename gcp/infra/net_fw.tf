############################################
# VPC
############################################
resource "google_compute_network" "vpc" {
  name                    = "jfz-vpc"
  auto_create_subnetworks = false
}

############################################
# Subnet
############################################
resource "google_compute_subnetwork" "subnet" {
  name          = "jfz-subnet"
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.10.0.0/24"
}

############################################
# Firewall Rules
############################################

# Allow SSH from your admin IP
resource "google_compute_firewall" "allow_ssh" {
  name    = "jfz-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.admin_ip]
}

# Allow internal traffic inside the VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "jfz-allow-internal"
  network = google_compute_network.vpc.name

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

  source_ranges = ["10.10.0.0/24"]
}

############################################
# Cloud Router + NAT
############################################
resource "google_compute_router" "router" {
  name    = "jfz-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "jfz-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
