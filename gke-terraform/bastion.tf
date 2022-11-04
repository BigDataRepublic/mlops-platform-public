locals {
  bastion_name = format("%s-bastion", var.cluster_name)
  bastion_zone = format("%s-c", var.region)
}

data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

module "bastion" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "4.1.0"

  network        = module.vpc.network_self_link
  subnet         = module.vpc.subnets_self_links[0]
  project        = module.enabled_google_apis.project_id
  host_project   = module.enabled_google_apis.project_id
  name           = local.bastion_name
  zone           = local.bastion_zone
  image_project  = "debian-cloud"
  image_family   = "debian-11"
  machine_type   = "f1-micro"
  disk_size_gb   = 10
  startup_script = data.template_file.startup_script.rendered
  members        = var.bastion_members
  shielded_vm    = "false"
}
