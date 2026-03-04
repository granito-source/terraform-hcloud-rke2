output "lb_ipv4" {
  depends_on = [
    hcloud_load_balancer_service.k8s_api,
    hcloud_server.master0,
    hcloud_server.master1,
    hcloud_server.master2
  ]
  value       = hcloud_load_balancer.cluster.ipv4
  description = "IPv4 address of the load balancer"
}

output "lb_ipv6" {
  depends_on = [
    hcloud_load_balancer_service.k8s_api,
    hcloud_server.master0,
    hcloud_server.master1,
    hcloud_server.master2
  ]
  value       = hcloud_load_balancer.cluster.ipv6
  description = "IPv6 address of the load balancer"
}

output "fqdn" {
  depends_on = [
    hcloud_load_balancer_service.k8s_api,
    hcloud_server.master0,
    hcloud_server.master1,
    hcloud_server.master2
  ]
  value       = local.fqdn
  description = "Fully qualified domain name of the cluster"
}

output "api_url" {
  depends_on = [
    hcloud_load_balancer_service.k8s_api,
    hcloud_server.master0,
    hcloud_server.master1,
    hcloud_server.master2
  ]
  value       = local.api_url
  description = "URL for the cluster's API"
}

output "ipv4_api_url" {
  depends_on = [
    hcloud_load_balancer_service.k8s_api,
    hcloud_server.master0,
    hcloud_server.master1,
    hcloud_server.master2
  ]
  value       = local.ipv4_api_url
  description = "URL for the cluster's API using only IPv4 address"
}

output "cluster_ca_certificate" {
  value       = base64decode(terraform_data.kubeconfig.output.clusters[0].cluster.certificate-authority-data)
  description = "TLS certificate of the cluster"
}

output "client_certificate" {
  value       = base64decode(terraform_data.kubeconfig.output.users[0].user.client-certificate-data)
  description = "TLS certificate of the client"
}

output "client_key" {
  value       = base64decode(terraform_data.kubeconfig.output.users[0].user.client-key-data)
  sensitive   = true
  description = "Private key of the client"
}

output "kubeconfig" {
  value       = local.kubeconfig
  sensitive   = true
  description = "Kubeconfig to access the cluster"
}

output "ssh_private_key" {
  value       = tls_private_key.root.private_key_openssh
  sensitive   = true
  description = "SSH private key to access the cluster's nodes"
}

output "master" {
  value = [
    {
      name         = hcloud_server.master0.name
      ipv4_address = hcloud_server.master0.ipv4_address
      ipv6_address = hcloud_server.master0.ipv6_address
    },
    {
      name         = hcloud_server.master1.name
      ipv4_address = hcloud_server.master1.ipv4_address
      ipv6_address = hcloud_server.master1.ipv6_address
    },
    {
      name         = hcloud_server.master2.name
      ipv4_address = hcloud_server.master2.ipv4_address
      ipv6_address = hcloud_server.master2.ipv6_address
    }
  ]
  description = "Master nodes (control plane)"
}

output "agent" {
  value = [
    for server in hcloud_server.agent : {
      name         = server.name
      ipv4_address = server.ipv4_address
      ipv6_address = server.ipv6_address
    }
  ]
  description = "Agent nodes"
}

output "ingress_class" {
  depends_on = [
    hcloud_load_balancer_service.http,
    hcloud_load_balancer_service.https,
    hcloud_server.master0,
    hcloud_server.master1,
    hcloud_server.master2
  ]
  value       = "nginx"
  description = "Ingress class configured in the cluster"
}
