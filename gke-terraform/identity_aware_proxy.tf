## Although the brand needs to be created once, it cannot be deleted so recreation fails :/
#resource "google_iap_brand" "project_brand" {
#  support_email     = "<you>@<your.domain>"
#  application_title = "Cloud IAP protected Application"
#}

# Make sure the brand already exists, it could be created with `google_iap_brand` as shown above
resource "google_iap_client" "mlops" {
  display_name = "mlops_client"
#  brand = google_iap_brand.project_brand.name
  # Obtain the value below by running gcloud alpha iap oauth-brands list
  brand = "projects/${data.google_project.default.number}/brands/${data.google_project.default.number}"
}

# Although this is not specific for individual backends, at least you will not have to provide it for every ingress
resource "google_iap_web_iam_binding" "iap_access" {
  role = "roles/iap.httpsResourceAccessor"
  members = [
    "domain:<your.domain>",
  ]
}
