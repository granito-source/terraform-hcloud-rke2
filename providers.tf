terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.60.1"
      configuration_aliases = [hcloud.dns]
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.8.1"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">= 0.2.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.2.1"
    }
  }
}
