provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  backend "gcs" {
    bucket = "mlops-platform-public"
    prefix = "gke-terraform/state"
  }
}

data "google_client_config" "default" {}
data "google_project" "default" {}
