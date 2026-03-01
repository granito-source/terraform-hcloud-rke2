terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.60.1"
      configuration_aliases = [ hcloud.dns ]
    }
    remote = {
      source  = "tenstad/remote"
      version = ">= 0.2.1"
    }
  }
}
