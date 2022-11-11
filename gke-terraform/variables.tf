variable "project_id" {
  type        = string
  default     = "mlops-platform-public"
  description = "The GCP project to deploy all components in"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "zone" {
  type    = string
  default = "europe-west1-c"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = "private-cluster-iap-bastion"
}

variable "network_name" {
  type        = string
  description = "The name of the network being created to host the cluster in"
  default     = "private-cluster-network"
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet being created to host the cluster in"
  default     = "private-cluster-subnet"
}

variable "subnet_ip" {
  type        = string
  description = "The cidr range of the subnet"
  default     = "10.10.10.0/24"
}

variable "ip_range_pods_name" {
  type        = string
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  type        = string
  description = "The secondary ip range to use for pods"
  default     = "ip-range-svc"
}

variable "bastion_members" {
  type        = list(string)
  description = "List of users, groups, SAs who need access to the bastion host, admins of the project get access automatically"
  default     = []
}

variable "gcp_secrets_sa" {
  type        = string
  description = "GCP SA for k8s workloads to access external secrets"
  default     = "google-external-secrets"
}

variable "k8s_secrets_sa" {
  type        = string
  description = "K8s SA for k8s workloads to access external secrets, prefixed by namespace"
  default     = "eso/k8s-external-secrets"
}
