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
  default     = "nbg1"
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

variable "cert_manager_version" {
  type        = string
  default     = null
  description = "cert-manager Helm chart version"
}

variable "longhorn_version" {
  type        = string
  default     = null
  description = "Longhorn Helm chart version"
}

variable "headlamp_version" {
  type        = string
  default     = null
  description = "Headlamp Helm chart version"
}

variable "write_config_files" {
  type        = bool
  default     = false
  description = "write SSK private key and client config if true"
}

variable "acme_email" {
  type        = string
  default     = null
  description = "Let's Encrypt ACME registration e-mail; if set it will create the cluster issuer"
}

variable "use_staging_issuer" {
  type        = bool
  default     = false
  description = "Use a staging issuer for the cert-manager"
}

variable "use_hcloud_storage" {
  type        = bool
  default     = false
  description = "deploy Hetzner Cloud CSI driver if true"
}

variable "use_longhorn" {
  type        = bool
  default     = false
  description = "deploy Longhorn distributed block storage if true"
}

variable "longhorn_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "password for Longhorn UI"
}

variable "longhorn_backup_target" {
  type        = string
  default     = null
  description = "Longhorn S3 backup target"
}

variable "longhorn_aws_endpoints" {
  type        = string
  default     = null
  description = "Longhorn S3 backup endpoints, must be defined if not using AWS"
}

variable "longhorn_aws_access_key_id" {
  type        = string
  default     = null
  description = "Longhorn S3 backup access key ID"
}

variable "longhorn_aws_secret_access_key" {
  type        = string
  sensitive   = true
  default     = null
  description = "Longhorn S3 backup secret access key"
}

variable "use_headlamp" {
  type        = bool
  default     = false
  description = "deploy Headlamp Kubernetes UI if true"
}
