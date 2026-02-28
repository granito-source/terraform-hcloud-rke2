locals {
  setup_dns = nonsensitive(var.hdns_token != "")
}

module "cluster" {
  source       = "./modules/hcloud_rke2"
  location     = var.location
  nodes_cidr   = var.nodes_cidr
  cluster_cidr = var.cluster_cidr
  service_cidr = var.service_cidr
  cluster_name = var.cluster_name
  domain       = var.domain
  master_type  = var.master_type
  agent_type   = var.agent_type
  agent_count  = var.agent_count
  image        = var.image
  rke2_version = var.rke2_version
}

module "dns" {
  count  = local.setup_dns ? 1 : 0
  source = "./modules/hdns"
  providers = {
    hcloud = hcloud.dns
  }
  zone         = var.domain
  cluster_name = var.cluster_name
  lb_ipv4      = module.cluster.lb_ipv4
  lb_ipv6      = module.cluster.lb_ipv6
}

module "ccm" {
  source             = "./modules/hcloud_ccm"
  hcloud_ccm_version = var.hcloud_ccm_version
  hcloud_token       = var.hcloud_token
  network            = module.cluster.network
  cluster_cidr       = module.cluster.cluster_cidr
}

module "csi" {
  depends_on            = [module.ccm]
  source                = "./modules/hcloud_csi"
  hcloud_csi_version    = var.hcloud_csi_version
  hcloud_secret         = module.ccm.hcloud_secret
  default_storage_class = var.hcloud_storage_is_default
}
