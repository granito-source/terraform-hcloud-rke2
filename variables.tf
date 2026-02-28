variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API token"
}

variable "hdns_token" {
  type        = string
  sensitive   = true
  default     = ""
  description = "Hetzner Cloud API token for DNS"
}

variable "nodes_cidr" {
  type        = string
  default     = "10.110.0.0/16"
  description = "subnet to use for nodes"
}

variable "cluster_cidr" {
  type        = string
  default     = "10.42.0.0/16"
  description = "subnet to use for pods"
}

variable "service_cidr" {
  type        = string
  default     = "10.43.0.0/16"
  description = "subnet to use for services"
}

variable "location" {
  type        = string
  default     = "hel1"
  description = "Hetzner location for the cluster"
}

variable "domain" {
  type        = string
  description = "domain of the cluster"
}

variable "cluster_name" {
  type        = string
  description = "name of the cluster"
}

variable "master_type" {
  type        = string
  default     = "cx23"
  description = "machine type to use for the master servers"
}

variable "agent_type" {
  type        = string
  default     = "cx23"
  description = "machine type to use for the agents"
}

variable "agent_count" {
  type        = number
  default     = 0
  description = "count of the agent servers"
}

variable "image" {
  type        = string
  default     = "ubuntu-24.04"
  description = "image to use for the servers"
}

variable "rke2_version" {
  type        = string
  default     = ""
  description = "target version of RKE2"
}

variable "hcloud_ccm_version" {
  type        = string
  default     = null
  description = "Cloud Controller Manager for Hetzner Cloud version"
}

variable "hcloud_csi_version" {
  type        = string
  default     = null
  description = "Hetzner Cloud CSI driver version"
}

variable "write_config_files" {
  type        = bool
  default     = false
  description = "write SSK private key and client config if true"
}

variable "hcloud_storage_is_default" {
  type        = bool
  default     = false
  description = "make Hetzner storage class default"
}
