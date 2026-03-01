# Terraform Module for RKE2 Cluster in Hetzner Cloud

This is a [Terraform](https://www.terraform.io/) module to create and
manage an [RKE2](https://docs.rke2.io/) cluster on
[Hetzner Cloud](https://www.hetzner.com/cloud/) platform. At very
minimum you will get out of the box:

* a highly available RKE2 cluster with three master nodes;
* a load balancer for the cluster's API and HTTP/HTTPS ingress traffic;
* [Hetzner Cloud Controller Manager](https://github.com/hetznercloud/hcloud-cloud-controller-manager);
* [Hetzner Cloud CSI Driver](https://github.com/hetznercloud/csi-driver);
* [Ingress NGINX Controller](https://kubernetes.github.io/ingress-nginx/)
  configured to work with the load balancer.

Optionally, you'll get DNS records for the cluster in Hetzner DNS.

## What You Need

* Hetzner Cloud account and read/write API tokens (you may choose have
  your DNS zone in a separate Hetzner project and therefore use a
  diferent token just for DNS);
* Terraform or [OpenTofu](https://opentofu.org/) CLI client.

## Basic Configuration

In your Terraform project configure the following variables. Add their
values to `terraform.tfvars`. Variable `hdns_token` needs a value if you
want to manage cluster's records in Hetzner DNS. It may be the same as
`hcloud_token`, in which case it would expect the DNS zone to be in
the same project as the cluster's resources.

```hcl
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
```

Configure providers used by the module. Adjust the versions if desired.

```hcl
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
```

Reference the module in the project's code.

```hcl
module "rke2" {
  source  = "granito-source/rke2/hcloud"
  version = "0.4.0"
  providers = {
    hcloud.dns = hcloud.dns
  }
  hcloud_token = var.hcloud_token
  setup_dns    = var.hdns_token != ""
  cluster_name = "mycluster"
  domain       = "mydomain.tld"
}
```

Configure the outputs.

```hcl
output "kubeconfig" {
  value     = module.rke2.kubeconfig
  sensitive = true
}

output "ssh_private_key" {
  value     = module.rke2.ssh_private_key
  sensitive = true
}
```

Initialize Terraform.

```shell
terraform init
```

Apply the configuration.

```shell
terraform apply
```

This will create an RKE2 cluster. The module's outputs can be used
as inputs to the rest of your infrastructure. To access the cluster's
API or the cluster's nodes, you can extract the content of the
configuration files using `output` command.

```shell
terraform output -raw kubeconfig >kubeconfig.yaml
terraform output -raw ssh_private_key >id_rsa
```

## Customizations

### Agent Nodes

You can create additional agent nodes in the cluster by specifying
`agent_count` parameter. This value can be adjusted after the initial
cluster creation.

```hcl
agent_count = 5
```

### Node Specifications and Location

You can specify the server type and the image to use for the nodes as
well as the location where create the nodes. By default,
the configuration uses `cx23` machines running `ubuntu-24.04` image
at `hel1` Hetzner location.

```hcl
location    = "fsn1"
master_type = "cax21"
agent_type  = "cax31"
image       = "ubuntu-22.04"
```

### DNS

If you own the DNS zone for the cluster and host it in Hetzner DNS,
you can provision `A` and `AAAA` wildcard records for the cluster's
load balancer. For that provide the value for `hdns_token` variable.

If you use the same project to manage the cluster and the DNS zone,
you may use the same token for the DNS. This will create the following
records:

```
*.mycluster.mydomain.tld.   300 A       <load balancer's IPv4>
*.mycluster.mydomain.tld.   300 AAAA    <load balancer's IPv6>
```

Having these records in place, you can access the cluster's Kubernetes
API using <https://api.mycluster.mydomain.tld:6443> URL. The Kubernetes
configuration file produced by the configuration will use that instead
of the IP address of the load balancer.

The applications hosted in the cluster and using ingress objects
to provide access to them, can use URLs similar to this one:
<https://myapp.mycluster.mydomain.tld/>.

### Software Versions

You can control what versions of software to deploy by setting these
variables.

```hcl
rke2_version       = "v1.35.1+rke2r1"
hcloud_ccm_version = "1.30.1"
hcloud_csi_version = "2.20.0"
```

These values only matter during the initial cluster creation or when
you rebuild the cluster nodes (see below).

The version of Ingress NGINX Controller is controlled by the
RKE2 version (see RKE2 Release Notes).

## Maintenance

### Rebooting a Node

You can reboot or power down any individual node in the cluster.
Here is the procedure.

1. Obtain the information about nodes in the cluster and find the
   node you want to reboot. For example: `mycluster-agent-9wsi3q`.
   ```shell
   kubectl get nodes --kubeconfig=config-mycluster.yaml
   ```
2. [Drain the node](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/).
   ```shell
   kubectl drain --ignore-daemonsets mycluster-agent-9wsi3q \
       --kubeconfig=config-mycluster.yaml
   ```
   Wait for the command to finish.
3. Power down or reboot the node.
4. Once the server is back up, mark the node as usable.
   ```shell
   kubectl uncordon mycluster-agent-9wsi3q \
       --kubeconfig=config-mycluster.yaml
   ```

### Rebuilding a Node

You can rebuild any individual node in the cluster be that an agent or
a master node. A new node is created first and then the existing node is
destroyed. Rebuilding all nodes one by one effectively upgrades the
cluster, ensuring the latest Linux image and the RKE2 version is used for
the nodes.

The procedure follows.

1. Obtain the information about nodes in the cluster and find the
   node you want to rebuild. Note the type of the node (master vs agent).
   For example: `mycluster-agent-9wsi3q`.
   ```shell
   kubectl get nodes --kubeconfig=config-mycluster.yaml
   terraform output agent
   ```
   For a master node use `output master`. Calculate the zero-based index
   of the node in the list. For example: `2`.
2. Drain the node.
   ```shell
   kubectl drain --ignore-daemonsets --delete-emptydir-data \
       mycluster-agent-9wsi3q \
       --kubeconfig=config-mycluster.yaml
   ```
   Wait for the command to finish.
3. Replace the name suffix.
   ```shell
   terraform apply -replace 'module.cluster.random_string.agent[2]'
   ```
   This will replace the node as described above. For master nodes use
   `module.cluster.random_string.master` instances. Monitor the cluster
   to ensure the workloads are stable before proceeding to replace
   another node.
4. In the end perform another apply to ensure the latest Kubeconfig
   is captured in the state.
   ```shell
   terraform apply
   ```

### Destroying the Cluster

If you are just playing with the setup, or setting up some experiments,
and need to remove the cluster cleanly, you can run the following
command. **ALL YOUR DATA IN THE CLUSTER WILL BE LOST!**

```shell
terraform destroy
```

## Credits

The original code in this repository comes from Sven Mattsen,
<https://github.com/scm2342/rke2-build-hetzner>. Further development
was influenced by ideas picked up from Felix Wenzel,
<https://github.com/wenzel-felix/terraform-hcloud-rke2>.
