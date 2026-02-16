resource "kubernetes_secret_v1" "hcloud" {
  metadata {
    namespace = "kube-system"
    name      = "hcloud"
  }
  data = {
    token   = var.hcloud_token
    network = var.network
  }
}

resource "helm_release" "hcloud_ccm" {
  namespace  = "kube-system"
  name       = "hcloud-ccm"
  repository = "https://charts.hetzner.cloud"
  chart      = "hcloud-cloud-controller-manager"
  version    = var.hcloud_ccm_version
  values = [
    <<-EOT
        kind: DaemonSet
        nodeSelector:
          kubernetes.io/os: linux
          node-role.kubernetes.io/master: "true"
        env:
          HCLOUD_TOKEN:
            valueFrom:
              secretKeyRef:
                name: ${kubernetes_secret_v1.hcloud.metadata[0].name}
                key: token
        networking:
          enabled: true
          clusterCIDR: ${var.cluster_cidr}
          network:
            valueFrom:
              secretKeyRef:
                name: ${kubernetes_secret_v1.hcloud.metadata[0].name}
                key: network
        EOT
  ]
}
