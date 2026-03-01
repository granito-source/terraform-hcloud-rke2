resource "hcloud_network" "private" {
  name     = var.network_name
  ip_range = var.network
}

data "hcloud_location" "cluster" {
  name = var.location
}

resource "hcloud_network_subnet" "nodes" {
  network_id   = hcloud_network.private.id
  type         = "cloud"
  network_zone = data.hcloud_location.cluster.network_zone
  ip_range     = var.nodes_cidr
}

resource "hcloud_load_balancer" "cluster" {
  name               = "${var.cluster_name}-cluster"
  load_balancer_type = var.lb_type
  location           = data.hcloud_location.cluster.name
  labels = {
    cluster = var.cluster_name
  }
}

resource "hcloud_load_balancer_network" "cluster" {
  load_balancer_id = hcloud_load_balancer.cluster.id
  subnet_id        = hcloud_network_subnet.nodes.id
}

resource "hcloud_load_balancer_target" "cluster" {
  depends_on       = [hcloud_load_balancer_network.cluster]
  type             = "label_selector"
  load_balancer_id = hcloud_load_balancer.cluster.id
  label_selector   = "cluster=${var.cluster_name},master=true"
  use_private_ip   = true
}

resource "hcloud_load_balancer_service" "supervisor" {
  load_balancer_id = hcloud_load_balancer.cluster.id
  protocol         = "tcp"
  listen_port      = 9345
  destination_port = 9345
  health_check {
    protocol = "tcp"
    port     = 9345
    interval = 5
    timeout  = 2
    retries  = 5
  }
}

resource "hcloud_load_balancer_service" "k8s_api" {
  depends_on       = [hcloud_load_balancer_target.cluster]
  load_balancer_id = hcloud_load_balancer.cluster.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443
  health_check {
    protocol = "tcp"
    port     = 6443
    interval = 5
    timeout  = 2
    retries  = 2
  }
}

resource "hcloud_load_balancer_service" "http" {
  load_balancer_id = hcloud_load_balancer.cluster.id
  protocol         = "tcp"
  listen_port      = 80
  destination_port = 80
  health_check {
    protocol = "tcp"
    port     = 80
    interval = 5
    timeout  = 2
    retries  = 2
  }
}

resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.cluster.id
  protocol         = "tcp"
  listen_port      = 443
  destination_port = 443
  health_check {
    protocol = "tcp"
    port     = 443
    interval = 5
    timeout  = 2
    retries  = 2
  }
}

data "hcloud_load_balancers" "cluster" {
  with_selector = "cluster=${var.cluster_name}"
}

locals {
  lb_deployed = length(data.hcloud_load_balancers.cluster.load_balancers) > 0
}
