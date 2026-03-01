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

locals {
  api_url      = "https://${var.setup_dns ? local.api : hcloud_load_balancer.cluster.ipv4}:6443"
  ipv4_api_url = "https://${hcloud_load_balancer.cluster.ipv4}:6443"
  kubeconfig   = <<-EOT
    apiVersion: v1
    kind: Config
    clusters:
    - cluster:
        certificate-authority-data: ${terraform_data.kubeconfig.output.clusters[0].cluster.certificate-authority-data}
        server: ${local.api_url}
      name: ${var.cluster_name}
    contexts:
    - context:
        cluster: ${var.cluster_name}
        namespace: kube-system
        user: system:admin@${var.cluster_name}
      name: system:admin@${var.cluster_name}
    current-context: system:admin@${var.cluster_name}
    preferences: {}
    users:
    - name: system:admin@${var.cluster_name}
      user:
        client-certificate-data: ${terraform_data.kubeconfig.output.users[0].user.client-certificate-data}
        client-key-data: ${terraform_data.kubeconfig.output.users[0].user.client-key-data}
    EOT
}
