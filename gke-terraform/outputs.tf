output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.name
}

output "location" {
  description = "Cluster location (region if regional cluster, zone if zonal cluster)"
  value       = module.gke.location
}

output "region" {
  description = "Subnet/Router/Bastion Host region"
  value       = var.region
}

output "endpoint" {
  sensitive   = true
  description = "Cluster endpoint. This one actually references the public IP, which is not accessible"
  value       = module.gke.endpoint
}

output "master_authorized_networks_config" {
  description = "Networks from which access to master is permitted"
  value       = module.gke.master_authorized_networks_config
}

output "router_name" {
  description = "Name of the router that was created"
  value       = module.cloud-nat.router_name
}

output "ca_certificate" {
  sensitive   = true
  description = "Cluster ca certificate (base64 encoded)"
  value       = module.gke.ca_certificate
}

output "network_name" {
  value       = module.vpc.network_name
  description = "The name of the VPC being created"
}

output "subnet_name" {
  value       = module.vpc.subnets_names[0]
  description = "The name of the VPC subnet being created"
}

output "get_credentials_command" {
  description = "gcloud get-credentials command to generate kubeconfig for the private cluster"
  value       = format("gcloud container clusters get-credentials --project %s --zone %s --internal-ip %s", data.google_project.default.name, module.gke.location, module.gke.name)
}

output "bastion_name" {
  description = "Name of the bastion host"
  value       = module.bastion.hostname
}

output "bastion_zone" {
  description = "Location of bastion host"
  value       = local.bastion_zone
}

output "bastion_ssh_command" {
  description = "gcloud command to ssh and port forward to the bastion host command"
  value       = format("gcloud beta compute ssh %s --tunnel-through-iap --project %s --zone %s -- -L8888:127.0.0.1:8888", module.bastion.hostname, data.google_project.default.name, local.bastion_zone)
}

output "bastion_kubectl_command" {
  description = "kubectl command using the local proxy once the bastion_ssh command is running"
  value       = "HTTPS_PROXY=localhost:8888 kubectl get pods --all-namespaces"
}

output "annotate_k8s_secrets_sa_command" {
  description = "Command to execute to give the k8s service account access to the gcp secrets"
  value       = "kubectl annotate serviceaccount k8s-external-secrets --namespace eso iam.gke.io/gcp-service-account=${google_service_account.gke_workload_secrets.email}"
}

output "public_ip_address" {
  description = "The public up to be configured in your own DNS management tool"
  value       = google_compute_global_address.load_balancer_ip.address
}