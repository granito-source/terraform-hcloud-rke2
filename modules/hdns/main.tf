data "hcloud_zone" "cluster" {
  name     = var.zone
}

resource "hcloud_zone_rrset" "wildcard_ipv4" {
  zone     = data.hcloud_zone.cluster.id
  name     = "*.${var.cluster_name}"
  type     = "A"
  ttl      = var.ttl
  records = [
    { value = var.lb_ipv4 }
  ]
}

resource "hcloud_zone_rrset" "wildcard_ipv6" {
  zone     = data.hcloud_zone.cluster.id
  name     = "*.${var.cluster_name}"
  type     = "AAAA"
  ttl      = var.ttl
  records = [
    { value = var.lb_ipv6 }
  ]
}
