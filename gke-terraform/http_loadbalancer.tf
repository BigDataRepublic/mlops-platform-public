# This certificate will need to be validated at the DNS side, which is not included in this repo
resource "google_compute_managed_ssl_certificate" "mlops" {
  name = "mlops-ssl"

  managed {
    domains = [
      "mlops.<your.domain>",
      "argocd.mlops.<your.domain>",
    ]
  }
}

resource "google_compute_global_address" "load_balancer_ip" {
  name = "load-balancer-ip"
}
