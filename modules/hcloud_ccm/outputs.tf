output "hcloud_secret" {
  value = kubernetes_secret_v1.hcloud.metadata[0].name
}
