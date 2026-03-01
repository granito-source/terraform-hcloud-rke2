data "hcloud_zone" "cluster" {
  provider = hcloud.dns
  count    = var.setup_dns ? 1 : 0
  name     = var.domain
}

resource "hcloud_zone_rrset" "wildcard_ipv4" {
  provider = hcloud.dns
  count    = var.setup_dns ? 1 : 0
  depends_on = [
    hcloud_load_balancer_service.k8s_api,
    hcloud_server.master0
  ]
  zone = data.hcloud_zone.cluster[0].id
  name = "*.${var.cluster_name}"
  type = "A"
  ttl  = var.dns_ttl
  records = [
    { value = hcloud_load_balancer.cluster.ipv4 }
  ]
}

resource "hcloud_zone_rrset" "wildcard_ipv6" {
  provider = hcloud.dns
  count    = var.setup_dns ? 1 : 0
  depends_on = [
    hcloud_load_balancer_service.k8s_api,
    hcloud_server.master0
  ]
  zone = data.hcloud_zone.cluster[0].id
  name = "*.${var.cluster_name}"
  type = "AAAA"
  ttl  = var.dns_ttl
  records = [
    { value = hcloud_load_balancer.cluster.ipv6 }
  ]
}
