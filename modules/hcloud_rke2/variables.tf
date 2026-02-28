variable "hcloud_token" {
  type        = string
  sensitive   = true
  description = "Hetzner Cloud API token"
}

variable "network_name" {
  type        = string
  default     = "private"
  description = "name of the network"
}

variable "network" {
  type        = string
  default     = "10.0.0.0/8"
  description = "network to use"
}

variable "nodes_cidr" {
  type        = string
  description = "subnet to use for nodes"
}

variable "cluster_cidr" {
  type        = string
  description = "subnet to use for pods"
}

variable "service_cidr" {
  type        = string
  description = "subnet to use for services"
}

variable "location" {
  type        = string
  description = "Hetzner location"
}

variable "domain" {
  type        = string
  description = "domain of the cluster"
}

variable "cluster_name" {
  type        = string
  description = "name of the cluster"
}

variable "lb_type" {
  type        = string
  default     = "lb11"
  description = "load balancer type"
}

variable "rke2_version" {
  type        = string
  default     = ""
  description = "version of RKE2 to install"
}

variable "master_type" {
  type        = string
  description = "machine type to use for the master servers"
}

variable "agent_type" {
  type        = string
  description = "machine type to use for the agents"
}

variable "agent_count" {
  type        = number
  description = "count of the agent servers"
}

variable "image" {
  type        = string
  description = "image to use for the servers"
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
