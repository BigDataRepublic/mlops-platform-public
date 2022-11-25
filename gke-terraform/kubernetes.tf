module "gke" {
  source                            = "terraform-google-modules/kubernetes-engine/google//modules/beta-private-cluster"
  version                           = "24.0.0"
  project_id                        = module.enabled_google_apis.project_id
  name                              = var.cluster_name
  region                            = var.region
  zones                             = [var.zone]
  network                           = module.vpc.network_name
  subnetwork                        = module.vpc.subnets_names[0]
  ip_range_pods                     = module.vpc.subnets_secondary_ranges[0].*.range_name[0]
  ip_range_services                 = module.vpc.subnets_secondary_ranges[0].*.range_name[1]
  enable_private_endpoint           = true
  add_cluster_firewall_rules        = false
  add_master_webhook_firewall_rules = true
  firewall_priority                 = 1000
  firewall_inbound_ports            = ["8443", "9443", "15017"]
  http_load_balancing               = true
  enable_private_nodes              = true
  master_ipv4_cidr_block            = "10.0.0.0/28"
  master_authorized_networks = [
    {
      cidr_block   = "${module.bastion.ip_address}/32"
      display_name = "Bastion Host"
    }
  ]
  grant_registry_access = true
  node_pools = [
    {
      name          = "safer-pool"
      min_count     = 1
      max_count     = 4
      auto_upgrade  = true
      node_metadata = "GKE_METADATA"
      machine_type  = "e2-medium"
      disk_size_gb  = 50
      spot          = true
    }
  ]
}
