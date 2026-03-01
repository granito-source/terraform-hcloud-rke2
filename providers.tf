terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.60.1"
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
  token = var.hdns_token
}
