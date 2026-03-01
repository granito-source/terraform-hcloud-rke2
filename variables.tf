variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API token"
}

variable "setup_dns" {
  type        = bool
  default     = false
  description = "Use Hezner DNS to configure records for the cluster"
}

variable "domain" {
  type        = string
  description = "Domain of the cluster"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "dns_ttl" {
  type        = number
  default     = 300
  description = "TTL of the cluster wildcard records"
}

variable "network_name" {
  type        = string
  default     = "private"
  description = "Name of the network"
}

variable "network" {
  type        = string
  default     = "10.0.0.0/8"
  description = "Network to use"
}

variable "nodes_cidr" {
  type        = string
  default     = "10.110.0.0/16"
  description = "Subnet to use for nodes"
}

variable "cluster_cidr" {
  type        = string
  default     = "10.42.0.0/16"
  description = "Subnet to use for pods"
}

variable "service_cidr" {
  type        = string
  default     = "10.43.0.0/16"
  description = "Subnet to use for services"
}

variable "location" {
  type        = string
  default     = "hel1"
  description = "Hetzner location for the cluster"
}

variable "lb_type" {
  type        = string
  default     = "lb11"
  description = "Load balancer type"
}

variable "master_type" {
  type        = string
  default     = "cx23"
  description = "Machine type to use for the master servers"
}

variable "agent_type" {
  type        = string
  default     = "cx23"
  description = "Machine type to use for the agents"
}

variable "agent_count" {
  type        = number
  default     = 0
  description = "Count of the agent servers"
}

variable "image" {
  type        = string
  default     = "ubuntu-24.04"
  description = "Image to use for the servers"
}

variable "rke2_version" {
  type        = string
  default     = ""
  description = "Version of RKE2 to install"
}

variable "hcloud_ccm_version" {
  type        = string
  default     = ""
  description = "Cloud Controller Manager for Hetzner Cloud version"
}

variable "hcloud_csi_version" {
  type        = string
  default     = ""
  description = "Hetzner Cloud CSI driver version"
}
