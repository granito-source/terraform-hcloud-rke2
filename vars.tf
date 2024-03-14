variable "hcloud_token" {
    type        = string
    sensitive   = true
    description = "Hetzner Cloud API token"
}

variable "hdns_token" {
    type        = string
    sensitive   = true
    default     = ""
    description = "Hetzner DNS API token"
}

variable "location" {
    type        = string
    default     = "nbg1"
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

variable "master_type" {
    type        = string
    default     = "cax11"
    description = "machine type to use for the master servers"
}

variable "agent_type" {
    type        = string
    default     = "cax11"
    description = "machine type to use for the agents"
}

variable "agent_count" {
    type        = number
    default     = 0
    description = "count of the agent servers"
}

variable "image" {
    type        = string
    default     = "ubuntu-22.04"
    description = "image to use for the servers"
}

variable "rke2_version" {
    type        = string
    default     = ""
    description = "version of RKE2 to install"
}

variable "hcloud_ccm_version" {
    type        = string
    default     = "1.19.0"
    description = "Cloud Controller Manager for Hetzner Cloud version"
}

variable "hcloud_csi_version" {
    type        = string
    default     = "2.6.0"
    description = "Hetzner Cloud CSI driver version"
}

variable "use_hcloud_storage" {
    type        = bool
    default     = false
    description = "deploy Hetzner Cloud CSI driver if true"
}

variable "acme_email" {
    type        = string
    default     = null
    description = "Let's Encrypt ACME registration e-mail"
}

variable "longhorn_user" {
    type        = string
    default     = "longhorn"
    description = "Longhorn UI user"
}
