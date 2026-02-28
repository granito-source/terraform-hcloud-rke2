resource "random_password" "token" {
  length  = 32
  special = false
}

locals {
  fqdn = "${var.cluster_name}.${var.domain}"
  api  = "api.${local.fqdn}"
}

resource "random_string" "master" {
  count   = 3
  length  = 6
  upper   = false
  special = false
}

resource "hcloud_server" "master0" {
  depends_on  = [hcloud_network_subnet.nodes]
  name        = "${var.cluster_name}-master-${random_string.master[0].id}"
  location    = data.hcloud_location.cluster.name
  server_type = var.master_type
  image       = var.image
  backups     = false
  ssh_keys    = [hcloud_ssh_key.root.id]
  user_data = templatefile("${path.module}/master_setup.sh.tpl", {
    rke2_version       = var.rke2_version
    token              = random_password.token.result
    initial            = !local.lb_deployed
    hcloud_token       = var.hcloud_token
    network_name       = var.network_name
    hcloud_ccm_version = var.hcloud_ccm_version
    hcloud_csi_version = var.hcloud_csi_version
    cluster_cidr       = var.cluster_cidr
    service_cidr       = var.service_cidr
    api                = local.api
    lb_ip              = hcloud_load_balancer_network.cluster.ip
    lb_ext_v4          = hcloud_load_balancer.cluster.ipv4
    lb_ext_v6          = hcloud_load_balancer.cluster.ipv6
  })
  labels = {
    cluster = var.cluster_name
    master  = "true"
  }
  network {
    network_id = hcloud_network.private.id
    alias_ips  = []
  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait | grep status:"
    ]
    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = tls_private_key.root.private_key_openssh
    }
  }
  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [random_string.master[0]]
    ignore_changes = [
      location,
      server_type,
      image,
      ssh_keys,
      user_data
    ]
  }
}

data "remote_file" "kubeconfig" {
  path = "/etc/rancher/rke2/rke2.yaml"
  conn {
    host        = hcloud_server.master0.ipv4_address
    user        = "root"
    private_key = tls_private_key.root.private_key_openssh
  }
}

resource "terraform_data" "kubeconfig" {
  input = yamldecode(data.remote_file.kubeconfig.content)
}

resource "hcloud_server" "master1" {
  depends_on  = [hcloud_server.master0]
  name        = "${var.cluster_name}-master-${random_string.master[1].id}"
  location    = data.hcloud_location.cluster.name
  server_type = var.master_type
  image       = var.image
  backups     = false
  ssh_keys    = [hcloud_ssh_key.root.id]
  user_data = templatefile("${path.module}/master_setup.sh.tpl", {
    rke2_version       = var.rke2_version
    token              = random_password.token.result
    initial            = false
    hcloud_token       = var.hcloud_token
    network_name       = var.network_name
    hcloud_ccm_version = var.hcloud_ccm_version
    hcloud_csi_version = var.hcloud_csi_version
    cluster_cidr       = var.cluster_cidr
    service_cidr       = var.service_cidr
    api                = local.api
    lb_ip              = hcloud_load_balancer_network.cluster.ip
    lb_ext_v4          = hcloud_load_balancer.cluster.ipv4
    lb_ext_v6          = hcloud_load_balancer.cluster.ipv6
  })
  labels = {
    cluster = var.cluster_name
    master  = "true"
  }
  network {
    network_id = hcloud_network.private.id
    alias_ips  = []
  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait | grep status:"
    ]
    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = tls_private_key.root.private_key_openssh
    }
  }
  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [random_string.master[1]]
    ignore_changes = [
      location,
      server_type,
      image,
      ssh_keys,
      user_data
    ]
  }
}

resource "hcloud_server" "master2" {
  depends_on  = [hcloud_server.master1]
  name        = "${var.cluster_name}-master-${random_string.master[2].id}"
  location    = data.hcloud_location.cluster.name
  server_type = var.master_type
  image       = var.image
  backups     = false
  ssh_keys    = [hcloud_ssh_key.root.id]
  user_data = templatefile("${path.module}/master_setup.sh.tpl", {
    rke2_version       = var.rke2_version
    token              = random_password.token.result
    initial            = false
    hcloud_token       = var.hcloud_token
    network_name       = var.network_name
    hcloud_ccm_version = var.hcloud_ccm_version
    hcloud_csi_version = var.hcloud_csi_version
    cluster_cidr       = var.cluster_cidr
    service_cidr       = var.service_cidr
    api                = local.api
    lb_ip              = hcloud_load_balancer_network.cluster.ip
    lb_ext_v4          = hcloud_load_balancer.cluster.ipv4
    lb_ext_v6          = hcloud_load_balancer.cluster.ipv6
  })
  labels = {
    cluster = var.cluster_name
    master  = "true"
  }
  network {
    network_id = hcloud_network.private.id
    alias_ips  = []
  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait | grep status:"
    ]
    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = tls_private_key.root.private_key_openssh
    }
  }
  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [random_string.master[2]]
    ignore_changes = [
      location,
      server_type,
      image,
      ssh_keys,
      user_data
    ]
  }
}

resource "random_string" "agent" {
  count   = var.agent_count
  length  = 6
  upper   = false
  special = false
}

resource "hcloud_server" "agent" {
  depends_on  = [hcloud_server.master2]
  count       = var.agent_count
  name        = "${var.cluster_name}-agent-${random_string.agent[count.index].id}"
  location    = data.hcloud_location.cluster.name
  server_type = var.agent_type
  image       = var.image
  backups     = false
  ssh_keys    = [hcloud_ssh_key.root.id]
  user_data = templatefile("${path.module}/agent_setup.sh.tpl", {
    rke2_version = var.rke2_version
    token        = random_password.token.result
    lb_ip        = hcloud_load_balancer_network.cluster.ip
  })
  labels = {
    cluster = var.cluster_name
    agent   = "true"
  }
  network {
    network_id = hcloud_network.private.id
    alias_ips  = []
  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait | grep status:"
    ]
    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = tls_private_key.root.private_key_openssh
    }
  }
  lifecycle {
    create_before_destroy = true
    replace_triggered_by  = [random_string.agent[count.index]]
    ignore_changes = [
      location,
      server_type,
      image,
      ssh_keys,
      user_data
    ]
  }
}
