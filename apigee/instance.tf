data "google_client_config" "current" {}

data "google_compute_network" "vpc" {
  name = "${var.project_id}-vpc"
}

resource "google_compute_global_address" "apigee_range" {
  name          = "apigee-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.apigee_network.id
}

resource "google_service_networking_connection" "apigee_vpc_connection" {
  network                 = google_compute_network.apigee_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee_range.name]
}

resource "google_apigee_organization" "apigee_org" {
  analytics_region   = var.region
  project_id         = data.google_client_config.current.project
  authorized_network = google_compute_network.apigee_network.id
  depends_on         = [google_service_networking_connection.apigee_vpc_connection]
}

resource "google_apigee_instance" "apigee_instance" {
  name     = "apigee_instance"
  location = var.region
  org_id   = google_apigee_organization.apigee_org.id
}

resource "google_apigee_environment" "apigee_env" {
  org_id   = google_apigee_organization.apigee_org.id
  name         = "apigee_env"
  description  = "Apigee Environment"
  display_name = "environment-1"
}

resource "google_apigee_instance_attachment" "" {
  instance_id  = google_apigee_instance.apigee_instance.id
  environment  = google_apigee_environment.apigee_env.name
}