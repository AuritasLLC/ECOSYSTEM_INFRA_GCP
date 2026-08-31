resource "google_compute_network" "asm_plus" {
  name                    = var.network_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.required["compute.googleapis.com"]]
}

resource "google_compute_subnetwork" "gke" {
  name          = var.subnetwork_name
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.asm_plus.id
  ip_cidr_range = var.subnetwork_cidr

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "asmplus-pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "asmplus-services"
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_global_address" "private_services" {
  name          = "asmplus-private-services"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_services_prefix_length
  network       = google_compute_network.asm_plus.id
}

resource "google_service_networking_connection" "private_services" {
  network                 = google_compute_network.asm_plus.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services.name]

  depends_on = [google_project_service.required["servicenetworking.googleapis.com"]]
}

resource "google_compute_global_address" "ingress" {
  name         = "asmplus-ingress-ip"
  project      = var.project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  depends_on = [google_project_service.required["compute.googleapis.com"]]
}
