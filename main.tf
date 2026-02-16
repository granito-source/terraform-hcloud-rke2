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
  count        = local.setup_dns ? 1 : 0
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
  count                 = var.use_hcloud_storage ? 1 : 0
  depends_on            = [module.ccm]
  source                = "./modules/hcloud_csi"
  hcloud_csi_version    = var.hcloud_csi_version
  hcloud_secret         = module.ccm.hcloud_secret
  default_storage_class = !var.use_longhorn
}

module "cert_manager" {
  depends_on           = [module.ccm]
  source               = "granito-source/cert-manager/kubernetes"
  version              = "~> 0.3.1"
  cert_manager_version = var.cert_manager_version
  keep_crds            = false
  acme_email           = var.acme_email
  ingress_class        = module.cluster.ingress_class
}

module "headlamp" {
  count            = var.use_headlamp ? 1 : 0
  depends_on       = [module.ccm]
  source           = "granito-source/headlamp/kubernetes"
  version          = "~> 0.2.1"
  headlamp_version = var.headlamp_version
  host             = "headlamp.${module.cluster.fqdn}"
  ingress_class    = module.cluster.ingress_class
  issuer_name      = var.use_staging_issuer ? module.cert_manager.staging_cluster_issuer : module.cert_manager.cluster_issuer
}

module "longhorn" {
  count                 = var.use_longhorn ? 1 : 0
  depends_on            = [module.ccm]
  source                = "granito-source/longhorn/kubernetes"
  version               = "~> 0.3.1"
  longhorn_version      = var.longhorn_version
  host                  = "longhorn.${module.cluster.fqdn}"
  password              = var.longhorn_password
  ingress_class         = module.cluster.ingress_class
  issuer_name           = var.use_staging_issuer ? module.cert_manager.staging_cluster_issuer : module.cert_manager.cluster_issuer
  backup_target         = var.longhorn_backup_target
  aws_endpoints         = var.longhorn_aws_endpoints
  aws_access_key_id     = var.longhorn_aws_access_key_id
  aws_secret_access_key = var.longhorn_aws_secret_access_key
}
