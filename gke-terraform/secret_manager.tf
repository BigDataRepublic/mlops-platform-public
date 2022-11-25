resource "google_service_account" "gke_workload_secrets" {
  account_id   = var.gcp_secrets_sa
  display_name = "SA for k8s workloads to access external secrets"
}

# Allows the service account to read from secret manager
resource "google_project_iam_binding" "secret_accessor" {
  project = data.google_project.default.name
  role    = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${google_service_account.gke_workload_secrets.email}",
  ]
}

# Attaches the service account as workload identity to the one usable by Kubernetes
resource "google_service_account_iam_binding" "gke_workload_binding" {
  service_account_id = google_service_account.gke_workload_secrets.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${data.google_project.default.name}.svc.id.goog[${var.k8s_secrets_sa}]",
  ]
}

# Save the IAP credentials as managed secret so that it can be used from Kubernetes
resource "google_secret_manager_secret" "iap_oauth_credentials" {
  secret_id = "iap-oauth-credentials"

  replication {
    automatic = true
  }
}
resource "google_secret_manager_secret_version" "iap_oauth_credentials_id" {
  secret = google_secret_manager_secret.iap_oauth_credentials.id
  secret_data = jsonencode({
    "client_id"     = google_iap_client.mlops.client_id
    "client_secret" = google_iap_client.mlops.secret
  })
}
