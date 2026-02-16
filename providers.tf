terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.60.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }
    remote = {
      source  = "tenstad/remote"
      version = "~> 0.2.1"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "hcloud" {
  alias = "dns"
  token = var.hdns_token != null ? var.hdns_token : var.hcloud_token
}

resource "terraform_data" "kubernetes" {
  input = {
    host                   = "https://${module.cluster.lb_ipv4}:6443"
    cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
    client_certificate     = base64decode(module.cluster.client_certificate)
    client_key             = base64decode(module.cluster.client_key)
  }
}

provider "kubernetes" {
  host                   = terraform_data.kubernetes.output.host
  cluster_ca_certificate = terraform_data.kubernetes.output.cluster_ca_certificate
  client_certificate     = terraform_data.kubernetes.output.client_certificate
  client_key             = terraform_data.kubernetes.output.client_key
}

provider "kubectl" {
  host                   = terraform_data.kubernetes.output.host
  cluster_ca_certificate = terraform_data.kubernetes.output.cluster_ca_certificate
  client_certificate     = terraform_data.kubernetes.output.client_certificate
  client_key             = terraform_data.kubernetes.output.client_key
}

provider "helm" {
  kubernetes = {
    host                   = terraform_data.kubernetes.output.host
    cluster_ca_certificate = terraform_data.kubernetes.output.cluster_ca_certificate
    client_certificate     = terraform_data.kubernetes.output.client_certificate
    client_key             = terraform_data.kubernetes.output.client_key
  }
}
